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

# Producers for the severity fixtures.
# A codechecker test is created for each to generate result.txt / result.json.
# The severities_test() targets in the parent package consume those generated
# files as data, so the unit tests always run against freshly produced output.

load(
    "@rules_cc//cc:defs.bzl",
    "cc_library",
)
load(
    "//:defs.bzl",
    "codechecker_test",
)

package(default_visibility = ["//test/unit/severities:__subpackages__"])

_PRODUCERS = {
    "clean": "clean.cc",
    "critical": "critical.cc",
    "high": "high.cc",
    "low": "low.cc",
    "medium": "medium.cc",
    "multi": "multi.cc",
}

[
    cc_library(
        name = "%s_lib" % severity,
        srcs = [src],
        tags = ["manual"],
    )
    for severity, src in _PRODUCERS.items()
]

[
    codechecker_test(
        name = severity,
        # With per_file we can address the result file directly.
        per_file = True,
        tags = ["manual"],
        targets = [":%s_lib" % severity],
    )
    for severity in _PRODUCERS
]
