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

foss_test(
    name = "zlib",
    bzlmod = False,
    tests = [
        ":codechecker_per_file",
        ":codechecker_test",
        ":compile_commands",
    ],
    url = "https://github.com/madler/zlib/releases/download/v1.3.2/zlib-1.3.2.tar.gz",
)

foss_test(
    # FIXME: compile commands is not in expected path
    name = "zlib_bzlmod",
    bzlmod = True,
    target = ":z",
    tests = [
        ":codechecker_per_file",
        ":codechecker_test",
        ":compile_commands",
    ],
    url = "https://github.com/madler/zlib/releases/download/v1.3.2/zlib-1.3.2.tar.gz",
)

foss_test(
    name = "yaml-cpp",
    bzlmod = False,
    tests = [
        ":codechecker_per_file",
        ":codechecker_test",
        ":compile_commands",
    ],
    url = "https://github.com/jbeder/yaml-cpp/archive/refs/tags/0.8.0.tar.gz",
)

foss_test(
    name = "yaml-cpp_bzlmod",
    bzlmod = True,
    target = ":yaml-cpp",
    tests = [
        ":codechecker_per_file",
        ":codechecker_test",
        ":compile_commands",
    ],
    url = "https://github.com/jbeder/yaml-cpp/archive/refs/tags/yaml-cpp-0.9.0.tar.gz",
)
