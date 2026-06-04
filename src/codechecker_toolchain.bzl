"""
This file provides the toolchain rule for CodeChecker
"""

CodeCheckerInfo = provider(
    doc = "This provider provides the executable path for CodeChecker and its related tools",
    fields = {
        "clang_tidy_bin": "clang-tidy executable",
        "clangsa_bin": "Clang executable",
        "codechecker_bin": "CodeChecker executable",
    },
)

def _codechecker_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        codecheckerinfo = CodeCheckerInfo(
            codechecker_bin = ctx.executable.codechecker_binary,
            clang_tidy_bin = ctx.attr.clang_tidy_binary,
            clangsa_bin = ctx.attr.clangsa_binary,
        ),
    )
    return [toolchain_info]

codechecker_toolchain = rule(
    implementation = _codechecker_toolchain_impl,
    attrs = {
        "clang_tidy_binary": attr.string(),
        "clangsa_binary": attr.string(),
        "codechecker_binary": attr.label(
            doc = "CodeChecker executable label",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
    },
)
