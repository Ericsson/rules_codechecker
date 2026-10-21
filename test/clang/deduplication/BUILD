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

load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_cc//cc:defs.bzl", "cc_library")
load("//:defs.bzl", "clang_tidy_test")

# A source reached through two targets with different arguments must not create
# conflicting analysis actions. The two libraries share shared.cc but compile
# it with different defines, so each variant is analyzed under a distinct name.
cc_library(
    name = "variant_a",
    srcs = ["shared.cc"],
    copts = ["-DVARIANT_A=1"],
)

cc_library(
    name = "variant_b",
    srcs = ["shared.cc"],
    copts = ["-DVARIANT_B=1"],
)

clang_tidy_test(
    name = "shared_analysis",
    tags = ["manual"],
    targets = [
        ":variant_a",
        ":variant_b",
    ],
)

# This is build-phase action, so building the analysis is the assertion
build_test(
    name = "shared_source",
    targets = [":shared_analysis"],
)
