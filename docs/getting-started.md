Getting Started
===============

## Prerequisites

We need the following tools:

- Bazel 7.7 or 8.5 (but not 9 yet)
- CodeChecker 6.27.3
- Clang and clang-tidy 21
- Python 3.11 or newer

### Environment Modules

If, by chance, Environment Modules (https://modules.sourceforge.net/)
are available in your system, you can just add the following modules:

```bash
module add bazel/8
module add clang/21
module add python/3.11
module add codechecker/6.27.3
```

## Install the tools

### RHEL 9

```bash
dnf update -y && dnf install -y wget llvm-toolset clang-tools-extra git python3 python3-pip gcc g++
```

### Ubuntu

```bash
sudo apt-get update --quiet && sudo apt-get install --no-install-recommends wget git python3 python3-pip python3-venv gcc g++ clang clang-tools clang-tidy
```

On some distributions, `clang`, `clang-tidy` and `clang-extdef-mapping` may be installed with a trailing version number (e.g. clang-extdef-mapping-18). In case your package didn't install a non-versioned symlink as well, you will need to manually change it:
```bash
update-alternatives --install /usr/bin/clang-extdef-mapping clang-extdef-mapping /usr/bin/clang-extdef-mapping-18 100
update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-18 100 
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 100
```

### Install CodeChecker

> [!Note]
> Currently the pip installed CodeChecker works best with these rules, which is our recommendation (as opposed to using a custom-built CodeChecker).

```bash
python3 -m venv ./codechecker_venv && \
source ./codechecker_venv/bin/activate && \
pip3 install codechecker
```

Install Bazel:
We recommend bazel 8.5.0
```bash
wget https://github.com/bazelbuild/bazel/releases/download/8.5.0/bazel-8.5.0-linux-x86_64 && \
chmod +x bazel-8.5.0-linux-x86_64 && \
sudo mv bazel-8.5.0-linux-x86_64 /usr/local/bin/bazel
```
Or choose a suitable binary for your system from this list:
https://github.com/bazelbuild/bazel/releases/tag/7.7.0
Alternatively follow the official guide at: https://bazel.build/install

> [!CAUTION]
> Don't use ccache! You should disable/remove/uninstall it, as the rules don't support it.
<!-- TODO When we make a decision on how to handle ccache in #36, expand this section -->


## Add the rules to your project

Add `rules_codechecker` as a
[Bazel module](https://bazel.build/external/module) in your `MODULE.bazel`:
<!--The git override part should not be needed after the project have been uploaded to a central registry
TODO: update this part when we have an actual release-->
```python
bazel_dep(name = "rules_codechecker")
git_override(
    module_name = "rules_codechecker",
    remote = "https://github.com/Ericsson/rules_codechecker.git",
    commit = "<latest commit id>",
)
```

No toolchain setup is needed: the rules ship a default toolchain that picks up
`CodeChecker`, `clang` and `clang-tidy` from your PATH. See
[Toolchains](toolchains) when you want to provide your own tools.


## Analyze your first target

Add a `codechecker_test()` to the `BUILD` file of the target you want to analyze:

```python
load("@rules_codechecker//:defs.bzl", "codechecker_test")

codechecker_test(
    name = "check",
    targets = [":your_target"],
)
```

Then run it:

```bash
bazel test //:check --test_output=all
```

The test fails when CodeChecker reports findings of `HIGH` severity or above.
On an existing codebase that is usually the case on the first run, so start
with the severities you want to enforce and lower the bar over time:

```python
codechecker_test(
    name = "check",
    severities = ["CRITICAL"],
    targets = [":your_target"],
)
```

Analysis results are written under `bazel-bin/`, see
[CodeChecker rules](codechecker) for what to do with them.
