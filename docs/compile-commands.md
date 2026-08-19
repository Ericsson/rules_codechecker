Compilation Database
====================

## compile_commands()

As generating a compilation database for C/C++ is a known pain point for bazel, this repository defines the Bazel rule `compile_commands()` rule which can be used independently of CodeChecker. The implementation is based on https://github.com/grailbio/bazel-compilation-database with some fixes on some tricky edge cases. To use it, include the following in your BUILD file:

```python
load(
    "@rules_codechecker//:defs.bzl",
    "compile_commands",
)
```

Then use `compile_commands()` rule passing build targets:

```python
compile_commands(
    name = "your_compile_commands_rule_name",
    targets = [
        "your_target",
    ],
)
```
You can find the generated `compile_commands.json` under `bazel-bin/`.


## compile_commands_aspect

The aspect behind `compile_commands()` is part of the
[public API](public-api), so your own rules can collect the same information.
Apply `compile_commands_aspect` to an attribute and read `SourceFilesInfo`
from the resulting targets:

```python
load(
    "@rules_codechecker//:defs.bzl",
    "SourceFilesInfo",
    "compile_commands_aspect",
)

def _my_rule_impl(ctx):
    for target in ctx.attr.targets:
        info = target[SourceFilesInfo]
        # info.compilation_db, info.headers, info.transitive_source_files
    return []

my_rule = rule(
    implementation = _my_rule_impl,
    attrs = {
        "targets": attr.label_list(aspects = [compile_commands_aspect]),
    },
)
```

## SourceFilesInfo

| Field                     | Content                                              |
|---------------------------|------------------------------------------------------|
| `compilation_db`          | compile commands with `file`, `command`, `directory` |
| `headers`                 | required header files                                |
| `transitive_source_files` | transitive source files of a target                  |


## platforms_transition

Rules that analyze for a specific platform need a transition, the sources have
to be collected in the configuration they are built for. `platforms_transition`
switches `//command_line_option:platforms` to the value of the rule's
`platform` attribute, and keeps the current platform when it is empty.

> [!IMPORTANT]
> The rule using it must have an attribute named `platform`,
> the transition reads it by that name.

```python
load(
    "@rules_codechecker//:defs.bzl",
    "compile_commands_aspect",
    "platforms_transition",
)

my_rule = rule(
    implementation = _my_rule_impl,
    cfg = platforms_transition,
    attrs = {
        "platform": attr.string(),
        "targets": attr.label_list(aspects = [compile_commands_aspect]),
    },
)
```
