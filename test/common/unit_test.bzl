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
Macro for generating unit tests for rules_codechecker.

Each unit_test() generates a local py_test that:
    Depends on an other action, and checks for patterns on its output.

Example:
    unit_test(
        name = "my_unit_test",
        files = ["my_target_file.ext"],
        patterns = ["my_pattern"],
        negative_patterns = ["my_negative_pattern"],
        regex_patterns = ["my_.*regex.*_pattern"],
        negative_regex_patterns = ["my_.*negative_regex.*_pattern"],
    )
"""

def unit_test(
        name,
        files,
        patterns = None,
        negative_patterns = None,
        regex_patterns = None,
        negative_regex_patterns = None,
        any = False,
        tags = [],
        size = "medium",
        **kwargs):
    """Generate a py_test that checks if provided patterns are in the files.

    Args:
        name: Test name.
        files: Path or glob to the files to be checked.
        patterns: Patterns that should be inside the files.
        negative_patterns: Patterns that shouldn't be inside the files.
        regex_patterns: Regex patterns that should be inside the files.
        negative_regex_patterns: Regex patterns that shouldn't be inside the files.
        any: If enabled its enough if every pattern is found in at least one file.
        tags: Additional test tags.
        size: Test size (default: medium).
        **kwargs: Forwarded to py_test.
    """
    if type(files) == "string":
        files = [files]
    if type(patterns) == "string":
        patterns = [patterns]
    if type(negative_patterns) == "string":
        negative_patterns = [negative_patterns]
    if type(regex_patterns) == "string":
        regex_patterns = [regex_patterns]
    if type(negative_regex_patterns) == "string":
        negative_regex_patterns = [negative_regex_patterns]

    python_args = ["--files"] + files
    if patterns:
        python_args.append("--patterns")
        python_args.extend(patterns)
    if negative_patterns:
        python_args.append("--negative_patterns")
        python_args.extend(negative_patterns)
    if regex_patterns:
        python_args.append("--regex_patterns")
        python_args.extend(regex_patterns)
    if negative_regex_patterns:
        python_args.append("--negative_regex_patterns")
        python_args.extend(negative_regex_patterns)
    if any:
        python_args.append("--any")

    native.py_test(
        name = name,
        srcs = ["//test/common:grep_check.py"], 
        main = "grep_check.py",
        args = python_args,
        local = True,
        tags = ["unit"] + tags,
        size = size,
        **kwargs
    )
