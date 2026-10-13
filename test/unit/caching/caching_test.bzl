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
Macro for generating caching verification tests.

Each caching_test() generates a py_test that:
    1. Creates a self-contained workspace in TEST_TMPDIR.
    2. Builds a codechecker_test target to prime the cache.
    3. Modifies a source file.
    4. Rebuilds with --subcommands.
    5. Asserts the expected number of CodeChecker actions re-ran.

Example:
    caching_test(
        name = "my_caching_test",
        target_name = "codechecker_caching",
        file_to_modify = "secondary.cc",
        expected_action_count = 1,
    )
"""

load("@rules_python//python:py_test.bzl", "py_test")

def caching_test(
        name,
        target_name,
        file_to_modify,
        expected_action_count,
        tags = [],
        size = "large",
        **kwargs):
    """Generate a py_test that verifies CodeChecker caching behavior.

    Args:
        name: Test name.
        target_name: The codechecker_test target to build in the inner workspace.
        file_to_modify: Source file to modify between builds.
        expected_action_count: Expected number of CodeChecker actions on rebuild.
        tags: Additional test tags.
        size: Test size (default: large).
        **kwargs: Forwarded to py_test.
    """
    py_test(
        name = name,
        srcs = ["//test/unit/caching:caching_check.py"],
        main = "//test/unit/caching:caching_check.py",
        args = [
            "--target_name",
            target_name,
            "--file_to_modify",
            file_to_modify,
            "--expected_action_count",
            str(expected_action_count),
        ],
        local = True,
        tags = ["unit"] + tags,
        size = size,
        **kwargs
    )
