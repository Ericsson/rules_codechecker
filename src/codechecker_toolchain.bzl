"""
This file provides the toolchain rule for CodeChecker
"""

CodeCheckerInfo = provider(
    doc = "This provider provides the executable path for CodeChecker",
    fields = [
        "executable",
    ],
)

def _codechecker_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        codecheckerinfo = CodeCheckerInfo(
            executable = ctx.attr.analyzer_binary,
        ),
    )
    return [toolchain_info]

codechecker_toolchain = rule(
    implementation = _codechecker_toolchain_impl,
    attrs = {
        "analyzer_binary": attr.string(),
    },
)
