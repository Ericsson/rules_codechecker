"""
This file provides the toolchain rule for CodeChecker
"""

CodeCheckerInfo = provider(
    doc = "This provider provides the executable path for CodeChecker and its related tools",
    fields = {
        "clang_tidy": "clang-tidy executable",
        "clangsa": "Clang executable",
        "codechecker": "CodeChecker executable",
    },
)

def _codechecker_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        codecheckerinfo = CodeCheckerInfo(
            codechecker = ctx.executable.codechecker,
            clang_tidy = ctx.executable.clang_tidy,
            clangsa = ctx.executable.clangsa,
        ),
    )
    return [toolchain_info]

codechecker_toolchain = rule(
    implementation = _codechecker_toolchain_impl,
    attrs = {
        "clang_tidy": attr.label(
            doc = "clang-tidy executable",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        "clangsa": attr.label(
            doc = "clang executable",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        "codechecker": attr.label(
            doc = "CodeChecker executable",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
    },
)
