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

unit_test(
    name = "codechecker_metadata_test",
    contains = [r"\"action_num\": 2,"],
    data = [":codechecker_multiple_source"],
    files = "test/unit/metadata/codechecker_multiple_source/codechecker-files/data/metadata.json",
)

unit_test(
    name = "per_file_metadata_test",
    data = [":per_file_multiple_source"],
    excludes = [r"\"action_num\": 2,"],
    files = "test/unit/metadata/per_file_multiple_source/data/metadata.json",
    # FIXME: remove when metadata is generated
    tags = ["manual"],
)
