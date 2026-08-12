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

load(
    "//src:codechecker_toolchain.bzl",
    "codechecker_toolchain",
)
load(
    "//test/unit/toolchain:toolchain_runfiles_test.bzl",
    "mock_executable",
    "runfiles_test_suite",
)

# --- Mock tools ---

# Mock CodeChecker with a runtime data dependency on helper_data.txt.
mock_executable(
    name = "mock_codechecker",
    src = "mock_codechecker.sh",
    data = ["helper_data.txt"],
)

mock_executable(
    name = "mock_clang",
    src = "mock_clang.sh",
)

mock_executable(
    name = "mock_clang_tidy",
    src = "mock_clang_tidy.sh",
)

# --- Mock toolchain ---

codechecker_toolchain(
    name = "runfiles_mock_toolchain",
    clang_tidy = ":mock_clang_tidy",
    clangsa = ":mock_clang",
    codechecker = ":mock_codechecker",
)

# --- Tests ---

runfiles_test_suite(name = "runfiles")
