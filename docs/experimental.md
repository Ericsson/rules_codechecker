Experimental Rules
==================

> [!IMPORTANT]
> The rules on this page are prototypes and are subject to changes or removal
> without notice. They are not part of the [public API](public-api) and are
> loaded from `@rules_codechecker//src`.


## clang_ctu_test()

> [!IMPORTANT]
> The rule is still in prototype status and is subject to changes or removal without notice.
> See [#32](https://github.com/Ericsson/rules_codechecker/issues/32).
> We are also actively pursuing better CTU support _using_ CodeChecker.

The Bazel rule `clang_ctu_test()` runs The Clang Static Analyzer with
[cross translation unit analysis](https://clang.llvm.org/docs/analyzer/user-docs/CrossTranslationUnit.html)
analysis without CodeChecker. To use it, add the following to your BUILD file:

```python
load(
    "@rules_codechecker//src:clang_ctu.bzl",
    "clang_ctu_test",
)

clang_ctu_test(
    name = "your_clang_ctu_rule_name",
    targets = [
        "your_target",
    ],
)
```


## Per-file CodeChecker analysis

The `per_file = True` option of `codechecker_test()` is a prototype as well,
see [CodeChecker rules](codechecker#per-file-codechecker-analysis).
