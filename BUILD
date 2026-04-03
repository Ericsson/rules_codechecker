load("@aspect_rules_lint//format:defs.bzl", "format_test")
load("@buildifier_prebuilt//:rules.bzl", "buildifier_test")

buildifier_test(
    name = "buildifier_native",
    diff_command = "diff -u",
    exclude_patterns = [
        "./.git/*",
    ],
    lint_mode = "warn",
    mode = "diff",
    no_sandbox = True,
    workspace = "//:WORKSPACE",
)

format_test(
    name = "format_test",
    # Temporary workaround for not being able to use -diff_command
    env = ["BUILDIFIER_DIFF='diff -u'"],
    no_sandbox = True,
    # TODO: extend with pylint
    starlark = "@buildifier_prebuilt//:buildifier",
    starlark_check_args = [
        "-lint=warn",
        "-warnings=all",
        "-mode=diff",
        # -u will always get passed to buildifier not diff_command
        #"-diff_command=\"diff -u\"",
    ],
    workspace = "//:WORKSPACE",
)
