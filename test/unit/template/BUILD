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

load(
    "@rules_cc//cc:defs.bzl",
    "cc_library",
)
load(
    "//src:codechecker.bzl",
    "codechecker_test",
)
load(
    "//test/unit:unit_test.bzl",
    "unit_test",
)

cc_library(
    name = "template_target",
    srcs = ["template.cpp"],
    tags = ["manual"],
)

codechecker_test(
    name = "template_codechecker",
    tags = ["manual"],
    targets = [
        "template_target",
    ],
)

codechecker_test(
    name = "template_per_file",
    per_file = True,
    tags = ["manual"],
    targets = [
        "template_target",
    ],
)

unit_test(
    name = "template_codechecker_test",
    contains = ["core.DivideZero"],
    data = [":template_codechecker"],
    excludes = ["Text not in file"],
    files = "test/unit/template/template_codechecker/codechecker.log",
    regex_patterns = ["[a-z]"],
)

unit_test(
    name = "template_per_file_test",
    contains = ["Division by zero"],
    data = [":template_per_file"],
    excludes = ["Text not in file"],
    files = "test/unit/template/template_per_file/**/*.plist",
    regex_patterns = ["[a-z]"],
    require_patterns_in_each_file = False,
)
