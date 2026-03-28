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

# -----------------------------------------------------------------------
# FOSS integration tests for rules_codechecker
#
# Each test downloads a real FOSS project, sets up a standalone Bazel
# project with rules_codechecker, and verifies the rules execute
# successfully via "bazel build".
#
# Run all:   bazel test //test/bazel/...
# Run one:   bazel test //test/bazel:zlib
#
# To add a new project: add a foss_test() call below.
# -----------------------------------------------------------------------

load(":foss_test.bzl", "foss_test")

BUILD_CONTENT = """
load("@rules_codechecker//src:codechecker.bzl", "codechecker_test")
load("@rules_codechecker//src:compile_commands.bzl", "compile_commands")

codechecker_test(
    name = "codechecker_test",
    targets = ["//{target}"],
)

codechecker_test(
    name = "codechecker_per_file",
    targets = ["//{target}"],
    per_file = True,
)

compile_commands(
    name = "compile_commands",
    targets = ["//{target}"],
)
"""

foss_test(
    name = "zlib",
    url = "https://github.com/madler/zlib/archive/5a82f71ed1dfc0bec044d9702463dbdf84ea3b71.tar.gz",
    build_content = BUILD_CONTENT.format(target = ":z"),
    targets = [
        ":codechecker_test",
        ":compile_commands",
        ":codechecker_per_file",
    ],
)

foss_test(
    name = "yaml_cpp",
    url = "https://github.com/jbeder/yaml-cpp/archive/refs/tags/0.8.0.tar.gz",
    build_content = BUILD_CONTENT.format(target = ":yaml-cpp"),
    targets = [
        ":codechecker_test",
        ":compile_commands",
        # FIXME: output 'analysis/codechecker_per_file/data/src-emit.cpp_clangsa.plist' was not created
        # ":codechecker_per_file",
    ],
)
