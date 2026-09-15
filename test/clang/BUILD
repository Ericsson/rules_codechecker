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
load("//:defs.bzl", "clang_tidy_test")
load(
    ":clang_test.bzl",
    "builtin_includes_test",
    "conlyopts_test",
    "copts_test",
    "cxxopts_not_in_c_test",
    "cxxopts_test",
)

# Defect free libraries: the tests check how the analysis is invoked
cc_library(
    name = "cpp_lib",
    srcs = ["clean.cc"],
    tags = ["manual"],
)

cc_library(
    name = "c_lib",
    srcs = ["clean.c"],
    tags = ["manual"],
)

clang_tidy_test(
    name = "cpp_analysis",
    tags = ["manual"],
    targets = [":cpp_lib"],
)

clang_tidy_test(
    name = "c_analysis",
    tags = ["manual"],
    targets = [":c_lib"],
)

builtin_includes_test(
    name = "builtin_includes",
    target_under_test = ":cpp_analysis",
)

copts_test(
    name = "copts",
    target_under_test = ":cpp_analysis",
)

cxxopts_test(
    name = "cxxopts",
    target_under_test = ":cpp_analysis",
)

conlyopts_test(
    name = "conlyopts",
    target_under_test = ":c_analysis",
)

cxxopts_not_in_c_test(
    name = "cxxopts_not_in_c",
    target_under_test = ":c_analysis",
)
