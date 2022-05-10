# rules_cuda examples

[rules_cuda](https://github.com/cloudhan/rules_cuda) is a starlark implementation of bazel rules for CUDA. This repo holds the extended examples for it.

## Get Started

```bash
git clone --recursive https://github.com/cloudhan/rules_cuda_examples.git
```

See the subfolders

Note: It is unconventional to use submodule a bazel project. It is purely for simplicity to avoid implementing repository rules. So notice the **`--recursive`**!

## Known issue

Sometimes the following error occurs:
```
cc1plus: fatal error: /tmp/tmpxft_00000002_00000019-2.cpp: No such file or directory
```

The problem is caused by nvcc use PID to determine temporary file name, and with `--spawn_strategy linux-sandbox` which is the default strategy on Linux, the PIDs nvcc sees are all very small numbers, say 2~4 due to sanboxing. `linux-sandbox` is not hermetic because [it mount root into the sandbox](https://docs.bazel.build/versions/main/command-line-reference.html#flag--experimental_use_hermetic_linux_sandbox), thus, `/tmp` is shared between sandboxes, which is causing name conflict under high parallelism. Similar problem has been reported at [nvidia forums](https://forums.developer.nvidia.com/t/avoid-generating-temp-files-in-tmp-while-nvcc-compiling/197657/10).

To avoid it:
  - Use `--spawn_strategy local` should eliminate the case because it will let nvcc sees true PIDs.
  - Use `--experimental_use_hermetic_linux_sandbox` should eliminate the case because it will avoid the sharing of `/tmp`.
  - Add `-objtemp` option to the command should reduce the case from happening.
