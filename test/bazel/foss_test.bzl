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

Each foss_test() generates a local sh_test that:
  1. Downloads a FOSS project into a temp directory
  2. Sets up a standalone Bazel project with rules_codechecker
  3. Runs "bazel build" on codechecker targets to verify the rules work

Example:
    foss_test(
        name = "zlib",
        url = "https://github.com/madler/zlib/archive/<commit>.tar.gz",
        build_content = "cc_library(...)",
        targets = [":codechecker_test"],
    )
"""

def foss_test(
        name,
        url,
        build_content,
        targets,
        tags = [],
        size = "enormous",
        **kwargs):
    """Generate an sh_test that runs rules_codechecker on a FOSS project.

    Args:
        name: Test name.
        url: URL to the source archive (.tar.gz).
        build_content: BUILD file content appended to the project.
        targets: Bazel targets to build inside the FOSS project.
        tags: Additional test tags.
        size: Test size (default: enormous, as these download + run bazel).
        **kwargs: Forwarded to sh_test.
    """
    native.sh_test(
        name = name,
        srcs = ["foss_test_runner.sh"],
        env = {
            "FOSS_URL": url,
            "FOSS_BUILD": build_content,
            "FOSS_TARGETS": " ".join(targets),
        },
        local = True,
        tags = ["foss", "external"] + tags,
        size = size,
        **kwargs
    )
