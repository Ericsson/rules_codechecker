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
Macro for generating FOSS integration tests for rules_codechecker.

Each foss_test() generates a local py_test that:
  1. Creates a Bazel project depending on the FOSS module and on our rules
  2. Runs "bazel build" on codechecker targets to verify the rules work
  3. Validates the outputs (compile_commands.json, codechecker artifacts)

The FOSS project comes from the Bazel Central Registry, therefore Bazel
downloads it, verifies it and resolves its dependencies, see
https://registry.bazel.build

Example:
    foss_test(
        name = "zlib",
        version = "1.3.1.bcr.7",
        tests = [":codechecker_test", ":compile_commands"],
    )
"""

load("@rules_python//python:defs.bzl", "py_test")

def foss_test(
        name,
        version,
        tests,
        module = None,
        target = None,
        tags = [],
        size = "large",
        **kwargs):
    """Generate a py_test that runs rules_codechecker on a FOSS project.

    Args:
        name: Test name.
        version: Version of the module in the Bazel Central Registry.
        tests: Analysis targets to build (e.g. codechecker_test, compile_commands).
        module: Name of the module. Defaults to <name>.
        target: The cc_library target to analyze. Defaults to @<module>//:<module>.
        tags: Additional test tags.
        size: Test size (default: large, as these download and run bazel).
        **kwargs: Forwarded to py_test.
    """
    if module == None:
        module = name
    if target == None:
        target = "@%s//:%s" % (module, module)

    py_test(
        name = name,
        srcs = ["foss_test_runner.py"],
        main = "foss_test_runner.py",
        args = [
            "-vvv",
            "--module=" + module,
            "--version=" + version,
            "--target=" + target,
            "--tests",
        ] + tests,
        local = True,
        tags = ["foss", "external"] + tags,
        size = size,
        **kwargs
    )
