load("@bazel_skylib//rules:copy_file.bzl", "copy_file")
load("@rules_cuda//cuda:defs.bzl", "cuda_library", "cuda_objects")

# Sometimes the following error occurs, especially when you Ctrl-C during the building and restart again
# cc1plus: fatal error: /tmp/tmpxft_00000002_00000019-2.cpp: No such file or directory
#  - copy all_reduce.cu to all_reduce_sum_i8, all_reduce_sum_f16, etc, before compiling reduce the case from happening.
#  - add -objtemp option to the command should reduce the case from happening.
#
# The error might not be recoverable on re-execute `bazel build ...`, in this case
#  - `bazel shutdown` then rebuild, if still not recoverable
#  - `bazel clean --expunge` then `bazel shutdown` then rebuild
#
# FIXME: address it!

# for nccl repo
def nccl_collectives(name, hdrs, deps, use_bf16):
    primitives = ["sendrecv", "all_reduce", "all_gather", "broadcast", "reduce", "reduce_scatter"]
    ops = ["sum", "prod", "min", "max", "premulsum", "sumpostdiv"]
    datatypes = ["i8", "u8", "i32", "u32", "i64", "u64", "f16", "f32", "f64"]
    if use_bf16:
        datatypes.append("bf16")

    cuda_objects(
        name = "device_common",
        srcs = [
            "nccl/src/collectives/device/functions.cu",
            "nccl/src/collectives/device/onerank_reduce.cu",
        ],
        hdrs = hdrs,
        copts = [
            "--extended-lambda",
            "-Xptxas=-maxrregcount=96",
            "-objtemp",
        ],
        deps = deps,
    )

    intermediate_targets = []
    for primitive in primitives:
        for opn, op in enumerate(ops):
            for dtn, dt in enumerate(datatypes):
                _name = "{}_{}_{}".format(primitive, op, dt)
                copy_file(
                    name = _name + "_rename",
                    src = "nccl/src/collectives/device/{}.cu".format(primitive),
                    out = "nccl/src/collectives/device/{}.cu".format(_name),
                )

                cuda_objects(
                    name = _name,
                    srcs = [":{}_rename".format(_name)],
                    hdrs = hdrs + native.glob(["nccl/src/collectives/device/*.h"]),
                    deps = deps,
                    copts = [
                        "--extended-lambda",
                        "-Xptxas=-maxrregcount=96",
                        "-objtemp",
                    ],
                    defines = ["NCCL_OP={}".format(opn), "NCCL_TYPE={}".format(dtn)],
                    includes = ["nccl/src/collectives/device"],
                )
                intermediate_targets.append(":" + _name)

    cuda_library(
        name = name,
        deps = intermediate_targets + [":device_common"],
        rdc = 1,
        alwayslink = 1,
    )

# for nccl-tests repo
def perf_binaries(name):
    perf_names = ["all_reduce", "all_gather", "broadcast", "reduce_scatter", "reduce", "alltoall", "scatter", "gather", "sendrecv", "hypercube"]

    cuda_library(
        name = "nccl_tests_common",
        srcs = ["nccl-tests/src/common.cu"],
        deps = [":nccl_tests_include", ":nccl"],
    )

    targets = []
    for perf_name in perf_names:
        cuda_library(
            name = perf_name,
            srcs = ["nccl-tests/src/{}.cu".format(perf_name)],
            deps = [":nccl_tests_include", ":nccl"],
        )

        bin_name = perf_name + "_perf"
        native.cc_binary(
            name = bin_name,
            srcs = [":nccl"],
            deps = [":nccl_tests_common", ":" + perf_name],
        )

        targets.append(":" + bin_name)

    native.filegroup(
        name = name,
        srcs = targets,
    )