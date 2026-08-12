package(default_visibility = ["//visibility:public"])

constraint_setting(
    name = "compiler",
)

constraint_value(
    name = "gcc12",
    constraint_setting = ":compiler",
)

constraint_value(
    name = "gcc14",
    constraint_setting = ":compiler",
)

constraint_value(
    name = "clang21",
    constraint_setting = ":compiler",
)

constraint_value(
    name = "clang22",
    constraint_setting = ":compiler",
)

platform(
    name = "gcc12_platform",
    constraint_values = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
        ":gcc12",
    ],
)

platform(
    name = "gcc14_platform",
    constraint_values = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
        ":gcc14",
    ],
)

platform(
    name = "clang21_platform",
    constraint_values = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
        ":clang21",
    ],
)

platform(
    name = "clang22_platform",
    constraint_values = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
        ":clang22",
    ],
)
