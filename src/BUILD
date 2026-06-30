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
load(":codechecker_toolchain.bzl", "codechecker_toolchain")

# Tool filter compile_commands.json file
# In bazel 6 we use our own python toolchain,
# therefore we cannot load from rules_python.
# buildifier: disable=native-py
py_binary(
    name = "compile_commands_filter",
    srcs = ["compile_commands_filter.py"],
    visibility = ["//visibility:public"],
)

# Build & Test script template
exports_files(
    [
        "codechecker_script.py",
        "per_file_script.py",
    ],
)

# The following are flags and default values for clang_tidy_aspect
filegroup(
    name = "clang_tidy_config_default",
    srcs = [],  # empty list: default configuration (.clang-tidy)
)

label_flag(
    name = "clang_tidy_config",
    build_setting_default = ":clang_tidy_config_default",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "clang_tidy_executable_default",
    srcs = [],  # empty list: system clang-tidy
)

label_flag(
    name = "clang_tidy_executable",
    build_setting_default = ":clang_tidy_executable_default",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "clang_tidy_additional_deps_default",
    srcs = [],
)

label_flag(
    name = "clang_tidy_additional_deps",
    build_setting_default = ":clang_tidy_additional_deps_default",
    visibility = ["//visibility:public"],
)

# named this by convention
# https://bazel.build/extending/toolchains#:~:text=%23%20By%20convention%2C%20toolchain%5Ftype%20targets%20are%20named%20%22toolchain%5Ftype%22%20and
toolchain_type(name = "toolchain_type")

codechecker_toolchain(
    name = "codechecker_local",
    clang_tidy = "@default_codechecker_tools//:clang_tidy",
    clangsa = "@default_codechecker_tools//:clang",
    codechecker = "@default_codechecker_tools//:CodeChecker",
)

toolchain(
    name = "codechecker_local_toolchain",
    toolchain = "codechecker_local",
    toolchain_type = ":toolchain_type",
)
