"""
This file provides the toolchain rule for CodeChecker
"""

CodeCheckerInfo = provider(
    doc = "This provider provides the executable path for CodeChecker and its related tools",
    fields = {
        "clang_tidy": "clang-tidy executable",
        "clangsa": "Clang executable",
        "codechecker": "CodeChecker executable",
        "runfiles": "List of tool inputs to spread into the `tools` of " +
                    "ctx.actions.run. It holds the FilesToRunProvider of the " +
                    "CodeChecker target (so Bazel materializes the launcher's " +
                    "'<name>.runfiles' tree, which the pip CodeChecker needs " +
                    "when it re-invokes itself) merged with a depset of the " +
                    "clang and clang-tidy executables and their data_runfiles.",
    },
)

def _codechecker_toolchain_impl(ctx):
    # CodeChecker is a (py_console_script_binary) launcher that re-invokes
    # itself, so it must be staged through its FilesToRunProvider to get its
    # '<name>.runfiles' tree. The clang tools only need their files, so they
    # are merged in as a plain depset. Both are passed together as the single
    # `runfiles` list, spread into the `tools` of every CodeChecker action.
    tool_files = depset(
        direct = [
            ctx.executable.clangsa,
            ctx.executable.clang_tidy,
        ],
        transitive = [
            # We also collect files necessary for these programs to run.
            # Those files should be declared with `data = [...]`
            # in the executable's target.
            ctx.attr.codechecker[DefaultInfo].default_runfiles.files,
            ctx.attr.clangsa[DefaultInfo].data_runfiles.files,
            ctx.attr.clang_tidy[DefaultInfo].data_runfiles.files,
        ],
    )
    toolchain_info = platform_common.ToolchainInfo(
        codecheckerinfo = CodeCheckerInfo(
            codechecker = ctx.executable.codechecker,
            clang_tidy = ctx.executable.clang_tidy,
            clangsa = ctx.executable.clangsa,
            # The CodeChecker FilesToRunProvider is first so Bazel materializes
            # its '<name>.runfiles' tree for self-reinvocation; the depset then
            # carries every tool file (CodeChecker's runfiles merged with the
            # clang tools) so consumers get a single, complete set of inputs.
            runfiles = [
                ctx.attr.codechecker[DefaultInfo].files_to_run,
                tool_files,
            ],
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
            default = "//src/codechecker_pip:CodeChecker",
            doc = "Executable target for `CodeChecker`. Defaults to the " +
                  "hermetic, pip-provided CodeChecker.",
            executable = True,
            cfg = "exec",
        ),
    },
)
