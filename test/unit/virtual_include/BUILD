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

# codechecker rules
load(
    "//src:codechecker.bzl",
    "codechecker_test",
)
load(
    "//test/unit:unit_test.bzl",
    "unit_test",
)

# codechecker rules
load(
    "//src:codechecker.bzl",
    "codechecker_test",
)

# Test for strip_include_prefix
cc_library(
    name = "test_inc",
    hdrs = glob(["inc/*.h"]),
    strip_include_prefix = "inc",
)

cc_library(
    name = "virtual_include",
    srcs = ["source.cc"],
    copts = ["-Wno-return-type"],
    deps = ["test_inc"],
)

# Simplest virtual include resolution test
codechecker_test(
    name = "codechecker_virtual_include",
    tags = [
        "manual",
    ],
    targets = [
        "virtual_include",
    ],
)

codechecker_test(
    name = "per_file_virtual_include",
    per_file = True,
    tags = [
        "manual",
    ],
    targets = [
        "virtual_include",
    ],
)

cc_library(
    name = "virtual_implementation_deps_include",
    srcs = ["source.cc"],
    implementation_deps = ["test_inc"],
    tags = ["manual"],
)

codechecker_test(
    name = "codechecker_impl_deps_include",
    tags = [
        "manual",
    ],
    targets = [
        "virtual_implementation_deps_include",
    ],
)

codechecker_test(
    name = "per_file_impl_deps_include",
    per_file = True,
    tags = [
        "manual",
    ],
    targets = [
        "virtual_implementation_deps_include",
    ],
)

unit_test(
    name = "per_file_plist_path_resolved_test",
    data = [":per_file_virtual_include"],
    files = "test/unit/virtual_include/per_file_virtual_include/**/*.plist",
    patterns = r"/_virtual_includes/",
)

unit_test(
    name = "codechecker_plist_path_resolved_test",
    any = True,
    data = [":codechecker_virtual_include"],
    files = "test/unit/virtual_include/codechecker_virtual_include/**/*.plist",
    # FIXME: In the postprocessed plists, all _virtual_include paths
    # should've been removed. Update to negative_patterns
    patterns = r"/_virtual_includes/",
)
