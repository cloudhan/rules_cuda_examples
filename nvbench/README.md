# Build

```bash
# CUDA_PATH environment is only needed if your installation is not at
# /usr/local/cuda and ptxas is not in path.
export CUDA_PATH=</path/to/your/cuda/sdk>

# change the sm_80 to your true arch
# change `--config gcc` to `--config msvc` if you are on windows.
bazel build --config gcc -c opt --cuda_archs=sm_80 //:nvbench_examples
```

Target `//:nvbench_examples` should produce:
  - `bazel-bin/nvbench.example.axes`
  - `bazel-bin/nvbench.example.enums`
  - `bazel-bin/nvbench.example.exec_tag_sync`
  - `bazel-bin/nvbench.example.exec_tag_timer`
  - `bazel-bin/nvbench.example.skip`
  - `bazel-bin/nvbench.example.stream`
  - `bazel-bin/nvbench.example.throughput`
  - `bazel-bin/nvbench.example.auto_throughput`

# Known issue

`//:nvbench_shared` target cause unresolved external symbol on Windows for unknown reason.
