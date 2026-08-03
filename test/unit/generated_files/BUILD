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

# cc_binary for simple C++ tests
load(
    "@rules_cc//cc:defs.bzl",
    "cc_binary",
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

# First, define the rule that generates our file.
genrule(
    name = "generate_header",
    outs = ["genrule_header.h"],
    # The code is written as such to avoid compiler warnings
    cmd = "echo 'void generated_function(){int y = 0; int x = 0/y;}' > $(location genrule_header.h)",
)

cc_binary(
    name = "genrule_header_cpp",
    srcs = [
        "genrule_header_consumer.cc",
        ":genrule_header.h",
    ],
    copts = ["-Wno-unused-variable"],
)

codechecker_test(
    name = "codechecker_genrule_header",
    tags = [
        "manual",
    ],
    targets = [
        ":genrule_header_cpp",
    ],
)

codechecker_test(
    name = "per_file_genrule_header",
    per_file = True,
    tags = [
        "manual",
    ],
    targets = [
        ":genrule_header_cpp",
    ],
)

genrule(
    name = "genrule_source",
    outs = [
        "genrule_source.cc",
    ],
    # The code is written as such to avoid compiler warnings
    cmd = "echo 'int main() { int y = 0; int x = 0/y; return x; }' > $(location genrule_source.cc)",
)

cc_binary(
    name = "genrule_source_cpp",
    srcs = [
        ":genrule_source.cc",
    ],
)

codechecker_test(
    name = "codechecker_genrule_source",
    tags = [
        "manual",
    ],
    targets = [
        ":genrule_source_cpp",
    ],
)

codechecker_test(
    name = "per_file_genrule_source",
    per_file = True,
    tags = [
        "manual",
    ],
    targets = [
        ":genrule_source_cpp",
    ],
)

compile_commands(
    name = "compile_commands_genrule_header",
    targets = [
        ":genrule_header_cpp",
    ],
)

compile_commands(
    name = "compile_commands_genrule_source",
    targets = [
        ":genrule_source_cpp",
    ],
)

unit_test(
    name = "codechecker_genrule_header_test",
    contains = ["defect(s) in genrule_header.h"],
    data = [":codechecker_genrule_header"],
    files = "test/unit/generated_files/codechecker_genrule_header/codechecker.log",
)

unit_test(
    name = "codechecker_genrule_source_test",
    contains = ["defect(s) in genrule_source.cc"],
    data = [":codechecker_genrule_source"],
    files = "test/unit/generated_files/codechecker_genrule_source/codechecker.log",
)

unit_test(
    name = "per_file_genrule_header_test",
    contains = [
        "genrule_header.h",
        "core.DivideZero",
    ],
    data = [":per_file_genrule_header"],
    excludes = "genrule_source.cc",
    files = "test/unit/generated_files/per_file_genrule_header/data/test-unit-generated_files-genrule_header_consumer.cc_clangsa.plist",
)

unit_test(
    name = "per_file_genrule_source_test",
    contains = [
        "genrule_source.cc",
        "core.DivideZero",
    ],
    data = [":per_file_genrule_source"],
    files = "test/unit/generated_files/per_file_genrule_source/data/bazel-out-k8-fastbuild-bin-test-unit-generated_files-genrule_source.cc_clangsa.plist",
)

unit_test(
    name = "compile_commands_genrule_source_test",
    data = [":compile_commands_genrule_source"],
    files = "test/unit/generated_files/compile_commands_genrule_source/compile_commands.json",
    regex_patterns = [r"\"file\":.*genrule_source\.cc"],
)

unit_test(
    name = "compile_commands_genrule_header_test",
    data = [":compile_commands_genrule_header"],
    files = "test/unit/generated_files/compile_commands_genrule_header/compile_commands.json",
    regex_patterns = [r"\"file\":.*genrule_header_consumer\.cc"],
)
