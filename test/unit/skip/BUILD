# Copyright 2023 Ericsson AB
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

# cc_binary for simple C++ tests
load(
    "@rules_cc//cc:defs.bzl",
    "cc_library",
)
load(
    "//src:codechecker.bzl",
    "codechecker_test",
)

cc_library(
    name = "simple_target",
    srcs = [
        "main.cc",
        "skip.cc",
        "skip.h",
        "skip2.cc",
        "skip2.h",
    ],
    tags = ["manual"],
)

# The monolithic rule uses codecheckers built in skipfile
# We expect that to be correct, further testing of it is unnecessary
codechecker_test(
    name = "codechecker_skipfile",
    skip = [
        "-*test/unit/skip/skip*",
    ],
    targets = [
        "simple_target",
    ],
)

# The per_file skip option must be implemented by us in starlark.
# Testing with multiple skip patterns is necessary
codechecker_test(
    name = "per_file_skipfile_full_path",
    per_file = True,
    skip = [
        "-*test/unit/skip/skip.cc",
    ],
    tags = ["manual"],
    targets = [
        "simple_target",
    ],
)

codechecker_test(
    name = "per_file_skipfile_folder_skip_path",
    per_file = True,
    skip = [
        "-*test/*/skip.cc",
    ],
    tags = ["manual"],
    targets = [
        "simple_target",
    ],
)

codechecker_test(
    name = "per_file_skipfile_both_files",
    per_file = True,
    skip = [
        "-*test/unit/skip/skip*",
    ],
    tags = ["manual"],
    targets = [
        "simple_target",
    ],
)
