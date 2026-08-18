# Bazel Rules for CodeChecker

Bazel rules for [CodeChecker](https://github.com/Ericsson/codechecker) and other tools for Code Analysis,  
like Clang-tidy, Clang analyzer, and compilation database (`compile_commands.json`) generation.


## Get Started

> [!Tip]
> You may try this on zlib:  
> `git clone https://github.com/madler/zlib.git`  
> `cd zlib`

### Prerequisites

- Bazel 7 or 8 (not 9 yet)
- CodeChecker 6.27.3
- Clang and clang-tidy 21
- Python 3.11 or newer

Check that you have all tools and versions:
```bash
bazel version
CodeChecker version
python3 --version
clang --version
clang-tidy --version
clang-extdef-mapping --version
which diagtool
```

### Add to `MODULE.bazel` file:

```starlark
bazel_dep(name = "rules_codechecker")
git_override(
    module_name = "rules_codechecker",
    remote = "https://github.com/Ericsson/rules_codechecker.git",
    commit = "cb57742eeaec172de042258a6053d87aee51e808",
)
```

### Add to `BUILD.bazel` (or `BUILD`) file:

```starlark
load("@rules_codechecker//:defs.bzl", "codechecker_test")

codechecker_test(
    name = "codechecker",
    targets = [":z"],
)
```

### Run:
```bash
bazel test //:codechecker --test_output=all
```


## Documentation

Full documentation: [docs/](docs/)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)
