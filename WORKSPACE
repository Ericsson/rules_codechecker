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

workspace(name = "rules_codechecker")

load(
    "@rules_codechecker//src:tools.bzl",
    "register_default_codechecker",
    "register_default_python_toolchain",
)

register_default_python_toolchain()

register_toolchains("@default_python_tools//:python_toolchain")

register_default_codechecker()

# Dev dependencies

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "buildifier_prebuilt",
    sha256 = "8ada9d88e51ebf5a1fdff37d75ed41d51f5e677cdbeafb0a22dda54747d6e07e",
    strip_prefix = "buildifier-prebuilt-6.4.0",
    urls = [
        "http://github.com/keith/buildifier-prebuilt/archive/6.4.0.tar.gz",
    ],
)

load("@buildifier_prebuilt//:deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_register_toolchains()

http_archive(
    name = "aspect_rules_lint",
    sha256 = "329cf5ba776a75b70049a5695e9ca29a25113230f4f447aff7102b62afe7c24a",
    strip_prefix = "rules_lint-1.11.0",
    url = "https://github.com/aspect-build/rules_lint/releases/download/v1.11.0/rules_lint-v1.11.0.tar.gz",
)

http_archive(
    name = "bazel_lib",
    sha256 = "0758ace949a93f709230a8e08ef35c5f0aacae2ff5d219b27da1d21d8233a709",
    strip_prefix = "bazel-lib-3.0.0-rc.0",
    url = "https://github.com/bazel-contrib/bazel-lib/releases/download/v3.0.0-rc.0/bazel-lib-v3.0.0-rc.0.tar.gz",
)

load("@bazel_lib//lib:repositories.bzl", "bazel_lib_dependencies")

bazel_lib_dependencies()

load(
    "@aspect_rules_lint//format:repositories.bzl",
    # Fetch additional formatter binaries you need:
    "rules_lint_dependencies",
)

rules_lint_dependencies()
