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
            doc = "Executable target for `clang-tidy`. Defaults to the `clang-tidy` binary discovered on `PATH`.",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            default = Label("@default_codechecker_tools//:clang_tidy"),
        ),
        "clangsa": attr.label(
            doc = "Executable target for `clang`, used for Clang Static Analyzer. Defaults to the `clang` binary discovered on `PATH`.",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            default = Label("@default_codechecker_tools//:clang"),
        ),
        "codechecker": attr.label(
            doc = "Executable target for `CodeChecker`. Defaults to the `CodeChecker` binary discovered on `PATH`.",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            default = Label("@default_codechecker_tools//:CodeChecker"),
        ),
    },
)
