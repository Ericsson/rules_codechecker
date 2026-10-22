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
    ":test.bzl",
    "private_dep_test",
    "public_dep_test",
)

# A public and a private dependency, each with its own include path
cc_library(
    name = "public_lib",
    hdrs = ["public/public.h"],
    includes = ["public"],
)

cc_library(
    name = "private_lib",
    hdrs = ["private/private.h"],
    includes = ["private"],
)

cc_library(
    name = "consumer",
    srcs = ["consumer.cc"],
    implementation_deps = [":private_lib"],
    deps = [":public_lib"],
)

# The analysis must run: it fails if the analyzer does not find the headers
clang_tidy_test(
    name = "consumer_analysis",
    targets = [":consumer"],
)

public_dep_test(
    name = "public_dep",
    target_under_test = ":consumer_analysis",
)

private_dep_test(
    name = "private_dep",
    target_under_test = ":consumer_analysis",
)
