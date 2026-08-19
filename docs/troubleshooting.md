Troubleshooting
===============

## ccache

> [!CAUTION]
> Don't use ccache! You should disable/remove/uninstall it, as the rules don't support it.

Check what `clang` resolves to, a path under `ccache` means the shim is in your
PATH:

```bash
which clang gcc
```


## Sandboxing

> [!WARNING]
> When debugging, or reporting a bug, take into consideration which sandbox mode bazel ran in.
> Be careful as the default sandbox can change if you ran
> [Bazel inside Docker](https://bazel.build/docs/sandboxing#:~:text=Both%20the%20linux,run%20%2D%2Dprivileged).

CodeChecker runs inside the sandbox, so paths it reports are sandbox paths.
This is why `skip` patterns have to be workspace-relative, see
[Skipping files](codechecker#skipping-files).


## Skipping the analysis

Filtering the tests away is not enough, the analysis happens at build time:

```bash
bazel test ... --test_tag_filters=-codechecker --build_tag_filters=-codechecker
```


## Reading the CodeChecker output

The analysis summary printed by CodeChecker and the findings reported by
`CodeChecker parse` are separate steps, and the summary may report
`Total analyzed compilation commands: 0` while findings are still reported.
Trust the reported findings and the exit status of the test.


## Tools and versions

The rules require the tools from the [Prerequisites](getting-started#prerequisites).
To see what is actually used, ask the tools themselves:

```bash
bazel version
CodeChecker version
clang --version
clang-tidy --version
clang-extdef-mapping --version
which diagtool
```
