Toolchains
==========

The rules locate the CodeChecker, Clang and clang-tidy executables through a
Bazel [toolchain](https://bazel.build/extending/toolchains). Modeling the tools
as a toolchain means the analysis rule (`codechecker_test`) never hardcodes binary paths:
Bazel resolves the correct tools at build time, and you can override them
per-project or per-platform without touching the rules themselves.


## The default toolchain

For most users no setup is required. `rules_codechecker` ships with a module
extension that provisions a default set of tools and a pre-registered
toolchain, both are set up by the `bazel_dep` on the rules.

> [!NOTE]
> The default tools resolve to the `CodeChecker`, `clang` and `clang-tidy`
> binaries available from PATH on your system (see the
> [Prerequisites](getting-started#prerequisites)).


## Providing your own tools

If you don't want the default system tools -- for example to pin a specific
CodeChecker version or point at a custom build —- you can define and register your own toolchain.

First, you will have to create or obtain labels for codechecker, clang and clang-tidy.

You may create such a label like this:
```python
filegroup(
    name = "clang",
    srcs = ["/usr/bin/clang"],
    visibility = ["//visibility:public"],
)
```

Then define an implementation in a BUILD file with `codechecker_toolchain()`:

```python
load(
    "@rules_codechecker//:defs.bzl",
    "codechecker_toolchain",
)

codechecker_toolchain(
    name = "codechecker_custom",
    clang_tidy  = "//example_target:clang-tidy",
    clangsa     = "//example_target:clang",
    codechecker = "//example_target:CodeChecker",
)

toolchain(
    name = "codechecker_custom_toolchain",
    toolchain = ":codechecker_custom",
    toolchain_type = "@rules_codechecker//:toolchain_type",
    # Optionally constrain which execution platform this applies to:
    # exec_compatible_with = ["@platforms//os:linux"],
)
```
Finally register it in your `MODULE.bazel`:
```python
register_toolchains("//path/to:codechecker_custom_toolchain")
```

> [!NOTE]
> Toolchains you register yourself take precedence over the default one if registered earlier.
