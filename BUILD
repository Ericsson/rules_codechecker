load("@buildifier_prebuilt//:rules.bzl", "buildifier_test")

buildifier_test(
    name = "buildifier",
    exclude_patterns = [
        "./.git/*",
    ],
    lint_mode = "warn",
    lint_warnings = ["all"],
    mode = "diff",
    no_sandbox = True,
    workspace = "//:WORKSPACE",
)
