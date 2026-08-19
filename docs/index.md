Bazel Rules for CodeChecker
===========================

Bazel rules for CodeChecker and other tools for Code Analysis,
including Clang-tidy, Clang analyzer, generating compilation database
(`compile_commands.json`) and others.

Start with [Getting Started](getting-started), it takes two snippets
and one `bazel test` command.

If you would like to report an issue or suggest a change
please read [Contributing](contributing).


## CodeChecker

CodeChecker is a static analysis infrastructure that conveniently manages
static analyzer engines such as the Clang Static Analyzer, Clang-tidy,
GCC Static Analyzer, CppCheck and Infer.

Read about CodeChecker:

* GitHub: https://github.com/Ericsson/codechecker
* Read the Docs: https://codechecker.readthedocs.io/

The main Bazel rule for CodeChecker is [`codechecker_test()`](codechecker#codechecker_test).


## Clang-Tidy

Clang-tidy is a fast static analyzer/linter for the C family of languages.
This repository provides Bazel rule [`clang_tidy_test()`](clang#clang_tidy_test)
to run clang-tidy natively (without CodeChecker).

Find more information about LLVM clang-tidy:

* LLVM: https://clang.llvm.org/extra/clang-tidy
* bazel_clang_tidy: https://github.com/erenon/bazel_clang_tidy


## Clang Static Analyzer

The Clang Static Analyzer (or `clang --analyze`) is among
the most sophisticated tools for C/C++ code analysis which implements
path-sensitive, inter-procedural analysis based on symbolic execution technique.
This repository provides the Bazel rule [`clang_analyze_test()`](clang#clang_analyze_test) which runs the
Clang Static Analyzer natively (without CodeChecker)

Find more information about LLVM Clang Static Analyzer:

* LLVM: https://clang.llvm.org/docs/ClangStaticAnalyzer.html


## Compilation Database

There is also a Bazel rule for generating a compilation database
(compile_commands.json) via [`compile_commands()`](compile-commands#compile_commands).
The current implementation is Bazel native and doesn't use `CodeChecker log`.
