Clang Rules
===========

The following rules are _not_ using CodeChecker.


## clang_tidy_test()

The Bazel rule `clang_tidy_test()` runs clang-tidy natively without CodeChecker.
To use it, add the following to your BUILD file:

```python
load(
    "@rules_codechecker//:defs.bzl",
    "clang_tidy_test",
)

clang_tidy_test(
    name = "your_rule_name",
    targets = [
        "your_target",
    ],
)
```


## clang_analyze_test()

The Bazel rule `clang_analyze_test()` runs The Clang Static Analyzer
natively without CodeChecker.
To use it, add the following to your BUILD file:

```python
load(
    "@rules_codechecker//:defs.bzl",
    "clang_analyze_test",
)

clang_analyze_test(
    name = "your_rule_name",
    targets = [
        "your_target",
    ],
)
```

> [!Note]
> Currently `clang_analyze_test()` rule does not support CTU (Cross Translation Unit) analysis.
> See [Experimental rules](experimental) for cross translation unit analysis.
