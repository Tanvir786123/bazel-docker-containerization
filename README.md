# bazel-docker-containerization

## Description
This repository provides a containerised runtime environment for executing [Bazel](https://bazel.build/), with the
overarching philosophy of showcasing what a **minimal** operating system environment looks like when running [Bazel](
  https://bazel.build/) tasks.

The focus here is to provide an environment that can register a no. of different toolchains and execute them within the
container environment.

For our demo, we have registered several C and C++ toolchains and have a small set of C++ programs that trigger common
errors. We aim to showcase the ability to run [compiler sanitization](https://hpc-wiki.info/hpc/Compiler_Sanitizers)
techniques within a unified [Docker](https://www.docker.com/) environment, and assert each toolchain's ability (where
appropriate). Our demo carefully assesses each toolchain and sanitiser combination, documenting caveats where
appropriate in this README.md file.

We have chosen to use the following toolchains within this repository:
1. [GCC 12](https://gcc.gnu.org/gcc-12/).
2. [GCC 14](https://gcc.gnu.org/gcc-14/).
3. [Clang 21](https://releases.llvm.org/21.1.0/tools/clang/docs/ReleaseNotes.html).
4. [Clang 22](https://releases.llvm.org/22.1.0/tools/clang/docs/ReleaseNotes.html).
5. [Hermetic LLVM](https://github.com/hermeticbuild/hermetic-llvm).

We have chosen to use the following sanitizers within this repository:
1. [ASan](https://github.com/google/sanitizers/wiki/addresssanitizer).
2. [LSan](https://clang.llvm.org/docs/LeakSanitizer.html).
3. [MSan](https://github.com/google/sanitizers/wiki/memorysanitizer).
4. [TSan](https://clang.llvm.org/docs/ThreadSanitizer.html).
5. [UBSan](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html).

Below is a matrix of toolchain-to-sanitizer combinations that were trialled during this demo:
| Sanitizer | GCC 12 | GCC 14 | Clang 21 | Clang 22 | Hermetic LLVM |
|-----------|:------:|:------:|:--------:|:--------:|:-------------:|
| ASan      |   ✅   |   ✅   |    ✅    |    ✅    |      ✅       |
| LSan      |   ✅   |   ✅   |    ✅    |    ✅    |      ✅       |
| UBSan     |   ✅   |   ✅   |    ✅    |    ✅    |      ✅       |
| TSan      |   ❌   |   ❌   |    ⚠️    |    ⚠️    |      ✅       |
| MSan      |   ❌   |   ❌   |    ⚠️    |    ✅    |      ✅       |

Matrix keys:
- ✅ Supported with the default container configuration.
- ⚠️ Supported, but requires the container to be run with `--security-opt seccomp=unconfined`.
- ❌ Unsupported in the current compiler/runtime environment.

Note the following:
- ❌ **GCC + TSan**: GCC TSan cannot run on the current host because its required shadow-memory address layout conflicts
with the host kernel's virtual-memory/ASLR layout.
- ❌ **GCC + MSan**: GCC does not implement MemorySanitizer, so `-fsanitize=memory` is not a supported GCC compiler
option.
- ⚠️ **Clang 21/22 + TSan**: Supported, but the container must be run with `--security-opt seccomp=unconfined` to allow
the TSan runtime to establish its required memory layout.
- ⚠️ **Clang 21 + MSan**: Supported, but the container must be run with `--security-opt seccomp=unconfined` to allow the
MSan runtime to establish its required memory layout.
- ✅ **Clang 22 + MSan**: Supported with the default container configuration.

From our experience, we have deduced that Linux kernels that disable or set the [SELinux](
  https://en.wikipedia.org/wiki/SELinux) module to `permissive` can execute the container **without** needing to set the
  `seccomp` argument to `unconfined`. However, we **do not** recommend this under any circumstances; rather, we wish to
  note this for the sake of documentation and sharing knowledge.

This repository also installs a prebuilt [Mold](https://github.com/rui314/mold) linker, which can be combined with the
toolchains and sanitizers, where applicable. The linker has **not** been added to the matrix because it does not
necessarily affect the toolchain-sanitizer combination in a meaningful manner; rather, it acts as a faster drop-in
replacement for existing Unix linkers.

## Getting Started

### Building the container
```bash
docker build -t bazel-docker-containerization .
```

### Running the container
The default run command is:
```bash
docker run --rm -it \
    -v "$(pwd):/workspace" \
    bazel-docker-containerization
```

However, if you are running one of the unique sanitizer-toolchain combinations (as per the toolchain-to-sanitizer
combination matrix), then you need to use the following run command (assuming the [SELinux](
  https://en.wikipedia.org/wiki/SELinux) module is enabled and set to `enforcing` within your environment):
```bash
docker run --rm -it \
    --security-opt seccomp=unconfined \
    -v "$(pwd):/workspace" \
    bazel-docker-containerization
```

### Running an example toolchain-sanitizer pair
This example walks you through compiling and running the [TSan](https://clang.llvm.org/docs/ThreadSanitizer.html)
program, and using the [Clang 22](https://releases.llvm.org/22.1.0/tools/clang/docs/ReleaseNotes.html) toolchain.

#### Building the `TSan` program
```bash
bazel build \
    --symlink_prefix="${BAZEL_SYMLINK_PREFIX}" \
    --toolchain_resolution_debug='@bazel_tools//tools/cpp:toolchain_type' \
    --platforms=//platforms:clang22_platform \
    --config=tsan \
    //sanitization-cpp:tsan
```

You should expect to see the following output:
```bash
2026/08/22 15:53:01 Downloading https://github.com/bazelbuild/bazel/releases/download/9.2.0/bazel-9.2.0-linux-x86_64...
Downloading: 62 MB out of 62 MB (100%) 
Extracting Bazel installation...
Starting local Bazel server (9.2.0) and connecting to it...
INFO: ToolchainResolution: Performing resolution of @@bazel_tools//tools/cpp:toolchain_type for target platform //platforms:clang22_platform

...

      ToolchainResolution:   Rejected toolchain //toolchains:clang21 (resolves to //toolchains:clang21_cc_toolchain) ; mismatching values: clang21
      ToolchainResolution:   Toolchain //toolchains:clang22 (resolves to //toolchains:clang22_cc_toolchain) is compatible with target platform, searching for execution platforms:
      ToolchainResolution:     Compatible execution platform @@platforms//host:host
      ToolchainResolution:   All execution platforms have been assigned a @@bazel_tools//tools/cpp:toolchain_type toolchain, stopping
      ToolchainResolution: Recap of selected @@bazel_tools//tools/cpp:toolchain_type toolchains for target platform //platforms:clang22_platform:
      ToolchainResolution:   Selected //toolchains:clang22_cc_toolchain to run on execution platform @@platforms//host:host
INFO: ToolchainResolution: Target platform //platforms:clang22_platform: Selected execution platform @@platforms//host:host, type @@bazel_tools//tools/cpp:toolchain_type -> toolchain //toolchains:clang22_cc_toolchain
INFO: Analyzed target //sanitization-cpp:tsan (102 packages loaded, 1035 targets configured).
INFO: Found 1 target...
Target //sanitization-cpp:tsan up-to-date:
  /tmp/bazel-bin/sanitization-cpp/tsan
INFO: Elapsed time: 31.800s, Critical Path: 0.74s
INFO: 7 processes: 5 internal, 2 processwrapper-sandbox.
INFO: Build completed successfully, 7 total actions
```

#### Launching the `TSan` program
As an example, to launch the `TSan` program with the [Clang 22](
  https://releases.llvm.org/22.1.0/tools/clang/docs/ReleaseNotes.html) toolchain:
```bash
bazel run \
    --symlink_prefix="${BAZEL_SYMLINK_PREFIX}" \
    --toolchain_resolution_debug='@bazel_tools//tools/cpp:toolchain_type' \
    --platforms=//platforms:clang22_platform \
    --config=tsan \
    //sanitization-cpp:tsan
```

You should expect to see the following output:
```bash
INFO: Analyzed target //sanitization-cpp:tsan (0 packages loaded, 0 targets configured).
INFO: Found 1 target...
Target //sanitization-cpp:tsan up-to-date:
  /tmp/bazel-bin/sanitization-cpp/tsan
INFO: Elapsed time: 0.177s, Critical Path: 0.00s
INFO: 1 process: 1 internal.
INFO: Build completed successfully, 1 total action
INFO: Running command line: /tmp/bazel-bin/sanitization-cpp/tsan
==================
WARNING: ThreadSanitizer: data race (pid=535)
  Write of size 4 at 0x588d3ee247d8 by thread T2:
    #0 increment() <null> (tsan+0xec478) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)
    #1 void std::__invoke_impl<void, void (*)()>(std::__invoke_other, void (*&&)()) <null> (tsan+0xecdb2) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)
    #2 std::__invoke_result<void (*)()>::type std::__invoke<void (*)()>(void (*&&)()) <null> (tsan+0xecd15) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)
    #3 void std::thread::_Invoker<std::tuple<void (*)()>>::_M_invoke<0ul>(std::_Index_tuple<0ul>) <null> (tsan+0xecccd) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)
    #4 std::thread::_Invoker<std::tuple<void (*)()>>::operator()() <null> (tsan+0xecc75) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)
    #5 std::thread::_State_impl<std::thread::_Invoker<std::tuple<void (*)()>>>::_M_run() <null> (tsan+0xecae9) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)
    #6 <null> <null> (libstdc++.so.6+0xecdb3) (BuildId: 753c6c8608b61d4e67be8f0c890e03e0aa046b8b)

  Previous write of size 4 at 0x588d3ee247d8 by thread T1:
    #0 increment() <null> (tsan+0xec478) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)
    #1 void std::__invoke_impl<void, void (*)()>(std::__invoke_other, void (*&&)()) <null> (tsan+0xecdb2) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)
    #2 std::__invoke_result<void (*)()>::type std::__invoke<void (*)()>(void (*&&)()) <null> (tsan+0xecd15) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)
    #3 void std::thread::_Invoker<std::tuple<void (*)()>>::_M_invoke<0ul>(std::_Index_tuple<0ul>) <null> (tsan+0xecccd) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)
    #4 std::thread::_Invoker<std::tuple<void (*)()>>::operator()() <null> (tsan+0xecc75) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)
    #5 std::thread::_State_impl<std::thread::_Invoker<std::tuple<void (*)()>>>::_M_run() <null> (tsan+0xecae9) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)
    #6 <null> <null> (libstdc++.so.6+0xecdb3) (BuildId: 753c6c8608b61d4e67be8f0c890e03e0aa046b8b)

  Location is global 'counter' of size 4 at 0x588d3ee247d8 (tsan+0x149b7d8)

  Thread T2 (tid=948, running) created by main thread at:
    #0 pthread_create <null> (tsan+0x657de) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)
    #1 std::thread::_M_start_thread(std::unique_ptr<std::thread::_State, std::default_delete<std::thread::_State>>, void (*)()) <null> (libstdc++.so.6+0xeceb0) (BuildId: 753c6c8608b61d4e67be8f0c890e03e0aa046b8b)
    #2 main <null> (tsan+0xec4d9) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)

  Thread T1 (tid=947, finished) created by main thread at:
    #0 pthread_create <null> (tsan+0x657de) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)
    #1 std::thread::_M_start_thread(std::unique_ptr<std::thread::_State, std::default_delete<std::thread::_State>>, void (*)()) <null> (libstdc++.so.6+0xeceb0) (BuildId: 753c6c8608b61d4e67be8f0c890e03e0aa046b8b)
    #2 main <null> (tsan+0xec4c7) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87)

SUMMARY: ThreadSanitizer: data race (/home/bazeluser/.cache/bazel/_bazel_bazeluser/eab0d61a99b6696edb3d2aff87b585e8/execroot/_main/bazel-out/k8-fastbuild/bin/sanitization-cpp/tsan+0xec478) (BuildId: cfc7031e4964c6cdd0a826984561a89c8d6c5e87) in increment()
==================
160853
ThreadSanitizer: reported 1 warnings
```

#### Verifying the linker
To inspect which linker was used during compilation, execute the following:
```bash
readelf -p .comment "${BAZEL_SYMLINK_PREFIX}bin/sanitization-cpp/tsan" 2>&1
```

You should expect to see:
```bash
String dump of section '.comment':
  [     0]  GCC: (Ubuntu 14.2.0-4ubuntu2~24.04.1) 14.2.0
  [    2d]  Ubuntu clang version 22.1.8 (++20260714014902+ca7933e47d3a-1~exp1~20260714135019.80)
```

#### Executing and using the Mold linker
Our `.bazelrc` file makes using the [Mold](https://github.com/rui314/mold) linker straightforward, as we can simply pass
an additional configuration flag to instruct Bazel to use the pre-built Mold linker when building our binary.

##### Building the binary
```bash
bazel build \
    --symlink_prefix="${BAZEL_SYMLINK_PREFIX}" \
    --toolchain_resolution_debug='@bazel_tools//tools/cpp:toolchain_type' \
    --platforms=//platforms:clang22_platform \
    --config=tsan \
    --config=mold \
    //sanitization-cpp:tsan
```

##### Running the binary
```bash
bazel run \
    --symlink_prefix="${BAZEL_SYMLINK_PREFIX}" \
    --toolchain_resolution_debug='@bazel_tools//tools/cpp:toolchain_type' \
    --platforms=//platforms:clang22_platform \
    --config=tsan \
    --config=mold \
    //sanitization-cpp:tsan
```

#### Verifying Mold usage
To verify that Mold was used to link the generated binary, inspect the `.comment` section using:
```bash
readelf -p .comment "${BAZEL_SYMLINK_PREFIX}bin/sanitization-cpp/tsan" 2>&1
```

You should expect to see output similar to:
```bash
String dump of section '.comment':
  [     0]  Ubuntu clang version 22.1.8 (++20260714014902+ca7933e47d3a-1~exp1~20260714135019.80)
  [    55]  GCC: (Ubuntu 14.2.0-4ubuntu2~24.04.1) 14.2.0
  [    82]  mold 2.42.0 (441dc1d1fd3c72f41bc9d30f440431d34738def3; compatible with GNU ld)
```

The presence of the Mold entry indicates that the binary was linked using the pre-built [Mold](
  https://github.com/rui314/mold) linker, version **2.42.0**.

## Authors and acknowledgements
Thank you to dom.mason@codethink.co.uk and tomas.veiga@codethink.co.uk for the assistance.
