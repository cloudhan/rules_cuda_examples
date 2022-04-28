# Build

This example only builds on linux platform!

```bash
# CUDA_PATH environment is only needed if your installation is not at
# /usr/local/cuda and ptxas is not in path.
export CUDA_PATH=</path/to/your/cuda/sdk>

# change the sm_80 to your true arch, otherwise, you may
#  - suffer from looooooooooooog jit linking and optimization time or
#  - unable to run the perf binaries if your gpu arch older than it
bazel build -c opt --cuda_archs=sm_80 //:perf_binaries
```

Target `//:perf_binaries` should produce:
  - `bazel-bin/all_reduce_perf`
  - `bazel-bin/all_gather_perf`
  - `bazel-bin/broadcast_perf`
  - `bazel-bin/reduce_scatter_perf`
  - `bazel-bin/reduce_perf`
  - `bazel-bin/alltoall_perf`
  - `bazel-bin/scatter_perf`
  - `bazel-bin/gather_perf`
  - `bazel-bin/sendrecv_perf`
  - `bazel-bin/hypercube_perf`

# Known issue

See the comment at the top of [`nccl.bzl`](./nccl.bzl) if you encounter:
```
cc1plus: fatal error: /tmp/tmpxft_...
````
