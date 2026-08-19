Examples
========

## In this repository

In [test/unit/legacy/BUILD](https://github.com/Ericsson/rules_codechecker/blob/main/test/unit/legacy/BUILD)
you can find examples for `codechecker_test()` and for `compile_commands()` rules.

For instance see targets `codechecker_pass` and `compile_commands_pass`.

Run all test Bazel targets:

```bash
bazel test ...
```

After that you can find all artifacts in `bazel-bin` directory:

```bash
# All codechecker_pass artifacts
ls bazel-bin/test/unit/legacy/codechecker_pass/

# compile_commands.json for compile_commands_pass
cat bazel-bin/test/unit/legacy/compile_commands_pass/compile_commands.json
```


## On an open source project

The [FOSS tests](https://github.com/Ericsson/rules_codechecker/tree/main/test/foss)
add these rules to upstream projects and analyze them in CI, which makes them
working end to end integration examples. Each project directory has an
`init.sh` that clones the project and appends the rules to its build files.

Trying the same by hand on zlib:

```bash
git clone https://github.com/madler/zlib.git
cd zlib
```

### Append to `MODULE.bazel`:

```python
bazel_dep(name = "rules_codechecker")
git_override(
    module_name = "rules_codechecker",
    remote = "https://github.com/Ericsson/rules_codechecker.git",
    commit = "<latest commit id>",
)
```

### Append to `BUILD.bazel` (or `BUILD`):

```python
load("@rules_codechecker//:defs.bzl", "codechecker_test")

codechecker_test(
    name = "check",
    targets = [":z"],
)
```

### Then run the analysis:

```bash
bazel test //:check --test_output=all
```
