filegroup(
    name = "all_sources",
    srcs = glob(
        ["**/*"],
        exclude = [
            "bazel-*/**",       # Exclude bazel symlinks
            ".git/**",
            "**/__pycache__/**",
        ],
    ),
    visibility = ["//visibility:public"],
)

sh_test(
    name = "integration_tests",
    srcs = ["test/test_runner.sh"],
    data = [
        ":all_sources",
        "//src:all_src_sources",
        "//test/unit/legacy:all_files",
        "//test/unit/parse:all_files",
        "//test/unit/implementation_deps:all_files",
        "//test/unit/generated_files:all_files",
        "//test/unit/config:all_files",
        "//test/unit/compile_flags:all_files",
        "//test/unit/caching:all_files",
        "//test/unit/argument_merge:all_files",
        "//test/unit/virtual_include:all_files",
    ],
    tags = [
        "local",
        "exclusive",
    ],
    size = "large",
    timeout = "long",
)
