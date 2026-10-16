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

# codechecker rules
load(
    "@rules_cc//cc:defs.bzl",
    "cc_library",
)
load(
    "//:defs.bzl",
    "codechecker_config",
    "codechecker_test",
)
load(
    "//test/unit:unit_test.bzl",
    "unit_test",
)

# C++ library containing a division by zero error, spread across 2 source files
cc_library(
    name = "test_div_zero",
    srcs = [
        "testdata/div_zero.c",
        "testdata/helper.c",
    ],
    hdrs = ["testdata/header.h"],
)

# This config file should make the analyzer run with --ctu
filegroup(
    name = "json_config_ctu_file",
    srcs = [":config_ctu.json"],
)

codechecker_config(
    name = "json_config_ctu",
    config_file = "json_config_ctu_file",
)

codechecker_test(
    name = "codechecker_json_ctu",
    config = "json_config_ctu",
    per_file = True,
    tags = ["manual"],
    targets = [
        "test_div_zero",
    ],
)

codechecker_test(
    name = "codechecker_bzl",
    analyze = [
        "--ctu",
    ],
    per_file = True,
    tags = ["manual"],
    targets = [
        "test_div_zero",
    ],
)

#The --ctu coming from the json, should also find the div_zero error, this test passing means it is not working properly
unit_test(
    name = "codechecker_json_test",
    data = [":codechecker_json_ctu"],
    excludes = ["core.DivideZero"],
    files = "test/unit/ctu_config/codechecker_json_ctu/**/*.plist",
)

unit_test(
    name = "codechecker_bzl_test",
    contains = ["core.DivideZero"],
    data = [":codechecker_bzl"],
    files = "test/unit/ctu_config/codechecker_bzl/**/*.plist",
    require_patterns_in_each_file = False,
)
