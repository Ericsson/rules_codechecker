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

cc_library(
    name = "multiple_source",
    srcs = [
        "main.cc",
        "other.cc",
    ],
    tags = ["manual"],
)

codechecker_test(
    name = "codechecker_multiple_source",
    tags = ["manual"],
    targets = [
        ":multiple_source",
    ],
)

codechecker_test(
    name = "per_file_multiple_source",
    per_file = True,
    tags = ["manual"],
    targets = [
        ":multiple_source",
    ],
)
