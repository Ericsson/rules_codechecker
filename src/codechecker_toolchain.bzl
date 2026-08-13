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
            default = "@default_codechecker_tools//:clang_tidy",
            doc = "Executable target for `clang-tidy`.",
            executable = True,
            cfg = "exec",
        ),
        "clangsa": attr.label(
            default = "@default_codechecker_tools//:clang",
            doc = "Executable target for `clang`, used for Clang Static Analyzer.",
            executable = True,
            cfg = "exec",
        ),
        "codechecker": attr.label(
            default = "@default_codechecker_tools//:CodeChecker",
            doc = "Executable target for `CodeChecker`.",
            executable = True,
            cfg = "exec",
        ),
    },
)
