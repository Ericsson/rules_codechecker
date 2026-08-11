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

load("@rules_cc//cc:defs.bzl", "cc_library")
load(
    ":compile_commands_analysis_test.bzl",
    "cc_compiler_info_test_suite",
    "collect_headers_test_suite",
    "get_compile_flags_no_duplicates_test",
    "get_compile_flags_test_suite",
    "get_sources_test_suite",
)
load(
    ":compile_commands_unit_test.bzl",
    "compile_commands_test_suite",
)

# =============================================================================
# Unit tests
# =============================================================================

compile_commands_test_suite(name = "compile_commands_tests")

# =============================================================================
# Analysis tests
# =============================================================================

# Shared test targets
# -------------------

cc_library(
    name = "collect_headers_tests_foo",
    srcs = ["testdata/foo.cc"],
    hdrs = ["testdata/foo.h"],
    tags = ["manual"],
)

cc_library(
    name = "collect_headers_tests_bar",
    srcs = ["testdata/bar.cc"],
    hdrs = ["testdata/bar.h"],
    tags = ["manual"],
)

cc_library(
    name = "collect_headers_tests_with_dep",
    srcs = ["testdata/foo.cc"],
    hdrs = ["testdata/foo.h"],
    tags = ["manual"],
    deps = [":collect_headers_tests_bar"],
)

cc_library(
    name = "collect_headers_tests_with_impl_dep",
    srcs = ["testdata/foo.cc"],
    hdrs = ["testdata/foo.h"],
    implementation_deps = [":collect_headers_tests_bar"],
    tags = ["manual"],
)

cc_library(
    name = "collect_headers_tests_no_hdrs",
    srcs = ["testdata/foo.cc"],
    tags = ["manual"],
)

# collect_headers
# ---------------

collect_headers_test_suite(name = "collect_headers_tests")

# get_sources
# -----------

get_sources_test_suite(name = "get_sources_tests")

# get_compile_flags
# -----------------

cc_library(
    name = "compile_flags_tests_with_defines",
    srcs = ["testdata/foo.cc"],
    hdrs = ["testdata/foo.h"],
    defines = ["MY_DEFINE=1"],
    tags = ["manual"],
)

cc_library(
    name = "compile_flags_tests_with_local_defines",
    srcs = ["testdata/foo.cc"],
    hdrs = ["testdata/foo.h"],
    local_defines = ["LOCAL_DEF=1"],
    tags = ["manual"],
)

cc_library(
    name = "compile_flags_tests_with_includes",
    srcs = ["testdata/foo.cc"],
    hdrs = ["testdata/foo.h"],
    includes = ["my/include/path"],
    tags = ["manual"],
)

cc_library(
    name = "compile_flags_tests_with_copts",
    srcs = ["testdata/foo.cc"],
    hdrs = ["testdata/foo.h"],
    copts = [
        "-Wall",
        "-Wextra",
    ],
    tags = ["manual"],
)

cc_library(
    name = "compile_flags_tests_dep_with_includes",
    srcs = ["testdata/bar.cc"],
    hdrs = ["testdata/bar.h"],
    includes = ["dep/include"],
    tags = ["manual"],
)

cc_library(
    name = "compile_flags_tests_with_dep_includes",
    srcs = ["testdata/foo.cc"],
    hdrs = ["testdata/foo.h"],
    tags = ["manual"],
    deps = [":compile_flags_tests_dep_with_includes"],
)

get_compile_flags_test_suite(name = "compile_flags_tests")

# BUG (manual): compile commands should not contain duplicate flags.
get_compile_flags_no_duplicates_test(
    name = "get_compile_flags_no_duplicates",
    tags = ["manual"],
    target_under_test = ":compile_flags_tests_with_dep_includes",
)

# _cc_compiler_info
# -----------------

cc_library(
    name = "cc_compiler_info_tests_cpp_target",
    srcs = ["testdata/foo.cc"],
    hdrs = ["testdata/foo.h"],
    tags = ["manual"],
)

cc_library(
    name = "cc_compiler_info_tests_c_target",
    srcs = ["testdata/bar.c"],
    hdrs = ["testdata/bar.h"],
    tags = ["manual"],
)

cc_compiler_info_test_suite(name = "cc_compiler_info_tests")
