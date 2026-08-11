# Copyright 2026 Ericsson AB
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Public API of rules_codechecker.

Usage:

    load("@rules_codechecker//:defs.bzl", "codechecker_test")
"""

# Clang rules, running without CodeChecker
load(
    "//src:clang.bzl",
    _clang_analyze_test = "clang_analyze_test",
    _clang_tidy_test = "clang_tidy_test",
)

# CodeChecker rules
load(
    "//src:codechecker.bzl",
    _codechecker_config = "codechecker_config",
    _codechecker_suite = "codechecker_suite",
    _codechecker_test = "codechecker_test",
)

# Toolchain rule, for providing custom tools
load(
    "//src:codechecker_toolchain.bzl",
    _codechecker_toolchain = "codechecker_toolchain",
)

# Compilation database (compile_commands.json) rule
load(
    "//src:compile_commands.bzl",
    _compile_commands = "compile_commands",
)

codechecker_test = _codechecker_test
codechecker_suite = _codechecker_suite
codechecker_config = _codechecker_config
codechecker_toolchain = _codechecker_toolchain
compile_commands = _compile_commands
clang_tidy_test = _clang_tidy_test
clang_analyze_test = _clang_analyze_test
