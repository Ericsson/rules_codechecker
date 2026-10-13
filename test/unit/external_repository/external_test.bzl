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

"""
Macro for external repository integration tests.

Each external_test() generates a py_test that:
    1. Creates a temporary Bazel workspace with external dependencies
    2. Runs a bazel command inside it
    3. Asserts on exit code and optionally on output file contents

Example:
    external_test(
        name = "compile_commands_test",
        target = ":compile_commands_isystem",
        action = "build",
        extra_flags = ["--features=external_include_paths"],
        output_file = "bazel-bin/compile_commands_isystem/compile_commands.json",
        contains = ["-isystem external/external_lib"],
        tags = ["manual"],
        size = "large",
    )
"""

load("@rules_python//python:py_test.bzl", "py_test")

# Source files made available to the inner build via the test runfiles,
# alongside the runner. Declared as a filegroup in the BUILD file.
_SRCS = "//test/unit/external_repository:external_test_srcs"

def external_test(
        name,
        target,
        action = "test",
        extra_flags = [],
        output_file = None,
        contains = None,
        tags = [],
        size = "large",
        **kwargs):
    """Generate a py_test that runs a bazel command in a temp workspace.

    Args:
        name: Test name.
        target: Bazel target to act on (e.g. ":codechecker_external_deps").
        action: Bazel action to run (default: "test").
        extra_flags: Additional flags to pass to the bazel command.
        output_file: Optional relative path to an output file to check.
        contains: Optional list of regex patterns to find in the output file.
        tags: Additional test tags.
        size: Test size (default: large).
        **kwargs: Forwarded to py_test.
    """
    if type(contains) == "string":
        contains = [contains]
    if type(extra_flags) == "string":
        extra_flags = [extra_flags]

    python_args = [
        "--repo_root",
        "$(rootpath //:MODULE.bazel)",
        "--action",
        action,
        "--target",
        target,
    ]

    # Output file assertions
    if output_file:
        python_args.extend(["--output_file", output_file])
    if contains:
        python_args.append("--contains")
        python_args.extend(["'{}'".format(pat) for pat in contains])

    # Extra flags go after -- to avoid argparse confusion with --flags
    if extra_flags:
        python_args.append("--")
        python_args.extend(extra_flags)

    py_test(
        name = name,
        srcs = ["//test/unit/external_repository:external_test_runner.py"],
        main = "//test/unit/external_repository:external_test_runner.py",
        args = python_args,
        data = [_SRCS, "//:MODULE.bazel"],
        # No other way to ensure integrated bazel can find the repository
        local = True,
        size = size,
        tags = tags,
        **kwargs
    )
