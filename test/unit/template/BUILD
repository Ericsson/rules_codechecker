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
    data = [":template_codechecker"],
    files = "test/unit/template/template_codechecker/codechecker.log",
    negative_patterns = ["Text not in file"],
    negative_regex_patterns = ["(This regex is not in the file)+"],
    patterns = ["core.DivideZero"],
    regex_patterns = ["[a-z]"],
)

unit_test(
    name = "template_per_file_test",
    data = [":template_per_file"],
    files = "test/unit/template/template_per_file/**/*.plist",
    negative_patterns = ["Text not in file"],
    negative_regex_patterns = ["(This regex is not in the file)+"],
    patterns = ["Division by zero"],
    regex_patterns = ["[a-z]"],
    require_patterns_in_each_file = False,
)
