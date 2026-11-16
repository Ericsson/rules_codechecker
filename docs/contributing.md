Contributing
============

Everything you need to work on `rules_codechecker` itself.
For using the rules in your project see [Getting Started](getting-started).


## Reporting issues

Navigate to the issues tab in GitHub, click on "New Issue", then select and
fill out the appropriate template. If any of the fields are confusing, feel
free to submit and we will help you to iron out the rest.

Please open an issue before a pull request, the
[pull request template](https://github.com/Ericsson/rules_codechecker/blob/main/.github/pull_request_template.md)
asks for the issue it addresses.


## Development environment

Everything is built and tested inside the Micromamba environment, which brings
its own Bazel, CodeChecker, Clang and Python:

```bash
source .ci/micromamba/init.sh
```

The script installs Micromamba under `.ci/micromamba/`, creates the
environment and activates it. It has to be sourced, a subshell cannot activate
anything in your shell. Options select the tool versions:

```bash
source .ci/micromamba/init.sh --bazel=8.5.1 --codechecker=6.27.3
source .ci/micromamba/init.sh --force          # recreate the environment
bash   .ci/micromamba/init.sh                  # only create, activate later
```

See [.ci/micromamba/README.md](https://github.com/Ericsson/rules_codechecker/blob/main/.ci/micromamba/README.md)
for the details.

Bazel auto-completion, once the environment is active:

```bash
source $(dirname $(realpath $(which bazel)))/bazel-complete.bash
```


## Directory structure

```tree
rules_codechecker/
├── .ci/
│   └── micromamba/                 Development and CI environment
├── docs/                           This documentation
├── src/                            Implementation of the rules
│   ├── BUILD                       Python targets and clang-tidy flags
│   ├── clang.bzl                   Clang-Tidy and Clang Analyzer rules
│   ├── clang_ctu.bzl               Clang Analyzer with CTU (PoC)
│   ├── codechecker.bzl             CodeChecker rules
│   ├── codechecker_config.bzl      CodeChecker configuration rule
│   ├── codechecker_script.py       Wrapper around CodeChecker
│   ├── codechecker_toolchain.bzl   Toolchain rule and provider
│   ├── common.bzl                  Helpers shared by the rules
│   ├── common.py                   Python helpers shared by the scripts
│   ├── compile_commands.bzl        Compilation database aspect
│   ├── compile_commands_filter.py  Filters compile_commands.json
│   ├── metadata_merge.py           Merges per-file metadata
│   ├── per_file.bzl                CodeChecker analyze --file (PoC)
│   ├── per_file_script.py          Wrapper around analyze --file
│   └── tools.bzl                   Default tools and module extension
├── test/                           Tests for the rules
│   ├── buildifier/                 Starlark linting
│   ├── clang/                      Clang-Tidy and Clang Analyzer rule tests
│   ├── foss/                       Rules on open source projects
│   ├── legacy/                     Legacy tests of the CodeChecker rules
│   ├── pylint/                     Pylint check of the repository
│   └── unit/                       Unit tests
├── BUILD                           Toolchain type and default toolchain
├── MODULE.bazel                    Module and its dependencies
└── defs.bzl                        Public API for our users
```


## Testing

Run all of these inside the Micromamba environment before submitting:

```bash
bazel test //...
pytest test
```

Or let one script do the whole round:

```bash
.ci/micromamba/run_tests.sh
```

On how to run or add a new test, see
[test/README.md](https://github.com/Ericsson/rules_codechecker/blob/main/test/README.md).



## Submitting a patch

Fill out the pull request template: why the change is needed, what it does, and
the issue it addresses. Keep the public API in mind: anything added to
[defs.bzl](public-api.md) is a promise to our users, anything under `src/` is not.

If you are a new contributor and the template is confusing, feel free to submit
the pull request and we will help you iron it out.
