load("@rules_cuda//cuda:defs.bzl", "cuda_library")

def nvbench_examples(name):
    examples = ["axes", "enums", "exec_tag_sync", "exec_tag_timer", "skip", "stream", "throughput", "auto_throughput"]

    cuda_library(
        name = "nvbench_main",
        srcs = ["nvbench/nvbench/main.cu"],
        deps = [":nvbench_include"],
        copts = ["-std=c++17"],
        alwayslink = 1,
    )

    targets = []
    for ex in examples:
        cuda_library(
            name = "_" + ex,
            srcs = ["nvbench/examples/{}.cu".format(ex)],
            deps = [":nvbench_include"],
            copts = ["-std=c++17"],
            alwayslink = 1,
        )

        bin_name = "nvbench.example." + ex
        native.cc_binary(
            name = bin_name,
            # srcs = [":nvbench_shared"],
            deps = [
                ":nvbench_static",
                ":nvbench_main",
                ":_" + ex,
                "@rules_cuda//cuda:runtime",
                "@local_cuda//:cuda",
            ],
        )
        targets.append(":" + bin_name)

    native.filegroup(
        name = name,
        srcs = targets,
    )
