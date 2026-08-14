"""Define a custom C++ toolchain configuration and Mold linker feature."""

load(
    "@rules_cc//cc:action_names.bzl",
    "ACTION_NAMES",
)
load(
    "@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "action_config",
    "feature",
    "flag_group",
    "flag_set",
    "tool",
    "tool_path",
)
load(
    "@rules_cc//cc:defs.bzl",
    "CcToolchainConfigInfo",
    "cc_common",
)

LINK_ACTIONS = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]

def _impl(ctx):
    tool_paths = [
        tool_path(
            name = "gcc",
            path = ctx.attr.compiler_path,
        ),
        tool_path(
            name = "ld",
            path = "/usr/bin/ld",
        ),
        tool_path(
            name = "ar",
            path = "/usr/bin/ar",
        ),
        tool_path(
            name = "cpp",
            path = ctx.attr.compiler_path,
        ),
        tool_path(
            name = "gcov",
            path = "/usr/bin/gcov",
        ),
        tool_path(
            name = "nm",
            path = "/usr/bin/nm",
        ),
        tool_path(
            name = "objdump",
            path = "/usr/bin/objdump",
        ),
        tool_path(
            name = "strip",
            path = "/usr/bin/strip",
        ),
    ]

    action_configs = [
        action_config(
            action_name = ACTION_NAMES.c_compile,
            enabled = True,
            tools = [
                tool(path = ctx.attr.compiler_path),
            ],
        ),
        action_config(
            action_name = ACTION_NAMES.cpp_compile,
            enabled = True,
            tools = [
                tool(path = ctx.attr.cxx_compiler_path),
            ],
        ),
        action_config(
            action_name = ACTION_NAMES.preprocess_assemble,
            enabled = True,
            tools = [
                tool(path = ctx.attr.compiler_path),
            ],
        ),
        action_config(
            action_name = ACTION_NAMES.assemble,
            enabled = True,
            tools = [
                tool(path = ctx.attr.compiler_path),
            ],
        ),
        action_config(
            action_name = ACTION_NAMES.cpp_link_executable,
            enabled = True,
            tools = [
                tool(path = ctx.attr.cxx_compiler_path),
            ],
        ),
        action_config(
            action_name = ACTION_NAMES.cpp_link_dynamic_library,
            enabled = True,
            tools = [
                tool(path = ctx.attr.cxx_compiler_path),
            ],
        ),
        action_config(
            action_name = ACTION_NAMES.cpp_link_nodeps_dynamic_library,
            enabled = True,
            tools = [
                tool(path = ctx.attr.cxx_compiler_path),
            ],
        ),
    ]

    features = [
        feature(
            name = "mold",
            enabled = False,
            flag_sets = [
                flag_set(
                    actions = LINK_ACTIONS,
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-B" + ctx.file.mold_ld.dirname,
                            ],
                        ),
                    ],
                ),
            ],
        ),
    ]

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = ctx.attr.toolchain_identifier,
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "k8",
        target_libc = "glibc",
        compiler = ctx.attr.compiler,
        abi_version = "local",
        abi_libc_version = "local",
        tool_paths = tool_paths,
        action_configs = action_configs,
        features = features,
        cxx_builtin_include_directories = ctx.attr.builtin_include_directories,
    )

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "compiler": attr.string(mandatory = True),
        "compiler_path": attr.string(mandatory = True),
        "cxx_compiler_path": attr.string(mandatory = True),
        "mold_ld": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "toolchain_identifier": attr.string(mandatory = True),
        "builtin_include_directories": attr.string_list(),
    },
    provides = [CcToolchainConfigInfo],
)
