load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load(":cc_toolchain_config.bzl", "cc_toolchain_config")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "empty",
)

filegroup(
    name = "mold_files",
    srcs = [
        "@mold_prebuilt//:mold",
    ],
)

# GCC 12

cc_toolchain_config(
    name = "gcc12_config",
    compiler = "gcc-12",
    compiler_path = "/usr/bin/gcc-12",
    cxx_compiler_path = "/usr/bin/g++-12",
    mold_ld = "@mold_prebuilt//:mold_ld",
    toolchain_identifier = "gcc12",
    builtin_include_directories = [
        "/usr/lib/gcc/x86_64-linux-gnu/12/include",
        "/usr/include/c++/12",
        "/usr/include/x86_64-linux-gnu/c++/12",
        "/usr/include/c++/12/backward",
        "/usr/include/x86_64-linux-gnu",
        "/usr/include",
    ],
)

cc_toolchain(
    name = "gcc12_cc_toolchain",
    toolchain_identifier = "gcc12",
    toolchain_config = ":gcc12_config",
    all_files = ":empty",
    compiler_files = ":empty",
    linker_files = ":mold_files",
    dwp_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 0,
)

toolchain(
    name = "gcc12",
    toolchain = ":gcc12_cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
        "//platforms:gcc12",
    ],
)

# GCC 14

cc_toolchain_config(
    name = "gcc14_config",
    compiler = "gcc-14",
    compiler_path = "/usr/bin/gcc-14",
    cxx_compiler_path = "/usr/bin/g++-14",
    mold_ld = "@mold_prebuilt//:mold_ld",
    toolchain_identifier = "gcc14",
    builtin_include_directories = [
        "/usr/lib/gcc/x86_64-linux-gnu/14/include",
        "/usr/include/c++/14",
        "/usr/include/x86_64-linux-gnu/c++/14",
        "/usr/include/c++/14/backward",
        "/usr/include/x86_64-linux-gnu",
        "/usr/include",
    ],
)

cc_toolchain(
    name = "gcc14_cc_toolchain",
    toolchain_identifier = "gcc14",
    toolchain_config = ":gcc14_config",
    all_files = ":empty",
    compiler_files = ":empty",
    linker_files = ":mold_files",
    dwp_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 0,
)

toolchain(
    name = "gcc14",
    toolchain = ":gcc14_cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
        "//platforms:gcc14",
    ],
)

# Clang 21

cc_toolchain_config(
    name = "clang21_config",
    compiler = "clang-21",
    compiler_path = "/usr/bin/clang-21",
    cxx_compiler_path = "/usr/bin/clang++-21",
    mold_ld = "@mold_prebuilt//:mold_ld",
    toolchain_identifier = "clang21",
    builtin_include_directories = [
        "/usr/lib/llvm-21/lib/clang/21/include",
        "/usr/lib/llvm-21/lib/clang/21/share",
        "/usr/include/c++/14",
        "/usr/include/x86_64-linux-gnu/c++/14",
        "/usr/include/c++/14/backward",
        "/usr/include/x86_64-linux-gnu",
        "/usr/include",
    ],
)

cc_toolchain(
    name = "clang21_cc_toolchain",
    toolchain_identifier = "clang21",
    toolchain_config = ":clang21_config",
    all_files = ":empty",
    compiler_files = ":empty",
    linker_files = ":mold_files",
    dwp_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 0,
)

toolchain(
    name = "clang21",
    toolchain = ":clang21_cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
        "//platforms:clang21",
    ],
)

# Clang 22

cc_toolchain_config(
    name = "clang22_config",
    compiler = "clang-22",
    compiler_path = "/usr/bin/clang-22",
    cxx_compiler_path = "/usr/bin/clang++-22",
    mold_ld = "@mold_prebuilt//:mold_ld",
    toolchain_identifier = "clang22",
    builtin_include_directories = [
        "/usr/lib/llvm-22/lib/clang/22/include",
        "/usr/lib/llvm-22/lib/clang/22/share",
        "/usr/include/c++/14",
        "/usr/include/x86_64-linux-gnu/c++/14",
        "/usr/include/c++/14/backward",
        "/usr/include/x86_64-linux-gnu",
        "/usr/include",
    ],
)

cc_toolchain(
    name = "clang22_cc_toolchain",
    toolchain_identifier = "clang22",
    toolchain_config = ":clang22_config",
    all_files = ":empty",
    compiler_files = ":empty",
    linker_files = ":mold_files",
    dwp_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 0,
)

toolchain(
    name = "clang22",
    toolchain = ":clang22_cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
        "//platforms:clang22",
    ],
)
