## manually patch nccl-tests

clang does not support `#pragma weak`

```bash
# assuming you are in the repo root
# remove all #pragma weak
sed -i 's/struct testEngine [^=]*/struct testEngine ncclTestEngine /g' nccl/nccl-tests/src/*.cu
sed -i 's/#pragma weak .*//g' nccl/nccl-tests/src/*.cu

# build with clang
bazel build --config clang -c opt --cuda_archs=sm_70 //:perf_binaries
```

If the clang is not symlinked as `clang`, for example `clang-16` at `/usr/bin/clang-16`,
add the following to the `.bazelrc`

```bazelrc
build:clang --repo_env=CC=clang-16
build:clang --repo_env=CUDA_CLANG_PATH=/usr/bin/clang-16
```
