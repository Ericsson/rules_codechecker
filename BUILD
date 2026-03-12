load("@buildifier_prebuilt//:rules.bzl", "buildifier_test")

buildifier_test(
    name = "buildifier",
    diff_command = "diff -u",
    exclude_patterns = [
        "./.git/*",
    ],
    lint_mode = "warn",
    mode = "diff",
    no_sandbox = True,
    workspace = "//:WORKSPACE",
)
