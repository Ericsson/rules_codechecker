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
    "//src:compile_commands.bzl",
    "compile_commands",
)
load(
    "//test/unit:unit_test.bzl",
    "unit_test",
)

cc_library(
    name = "dep_lib",
    srcs = [
        "dep.cpp",
    ],
    hdrs = ["dep.h"],
    tags = ["manual"],
)

cc_library(
    name = "main_lib",
    srcs = [
        "main.cpp",
    ],
    implementation_deps = ["dep_lib"],
    tags = ["manual"],
)

compile_commands(
    name = "compile_commands_implementation_deps",
    tags = ["manual"],
    targets = [
        ":main_lib",
    ],
)

codechecker_test(
    name = "codechecker_implementation_deps",
    tags = ["manual"],
    targets = [
        ":main_lib",
    ],
)

codechecker_test(
    name = "per_file_implementation_deps",
    per_file = True,
    tags = ["manual"],
    targets = [
        ":main_lib",
    ],
)

unit_test(
    name = "codechecker_implementation_deps_test",
    contains = [
        "core.DivideZero",
        "cplusplus.NewDeleteLeaks",
    ],
    data = [":codechecker_implementation_deps"],
    files = "test/unit/implementation_deps/codechecker_implementation_deps/codechecker.log",
)

unit_test(
    name = "per_file_implementation_deps_test",
    contains = [
        "core.DivideZero",
        "cplusplus.NewDeleteLeaks",
    ],
    data = [":per_file_implementation_deps"],
    files = "test/unit/implementation_deps/per_file_implementation_deps/**/*.plist",
    require_patterns_in_each_file = False,
)

unit_test(
    name = "compile_commands_implementation_deps_test",
    contains = [
        "main.cpp",
        "dep.cpp",
    ],
    data = [":compile_commands_implementation_deps"],
    files = "test/unit/implementation_deps/compile_commands_implementation_deps/compile_commands.json",
)
