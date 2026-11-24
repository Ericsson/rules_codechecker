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

"""
Toolchain setup for python and CodeChecker
Provide tools used by more rulesets.
"""

def _codechecker_local_repository_impl(repository_ctx):
    codechecker_bin_path = repository_ctx.which("CodeChecker")
    if not codechecker_bin_path:
        fail("ERROR! CodeChecker is not detected")
    result = repository_ctx.execute(["CodeChecker", "version", "-o", "json"])
    if result.return_code != 0:
        fail("Failed to query CodeChecker version")
    version_output = result.stdout.strip()
    full_version_data = json.decode(version_output)
    codechecker_version = full_version_data.get("analyzer", {}).get("base_package_version")
    if codechecker_version == None:
        fail("CodeChecker version could not be parsed!")
    clang_bin_path = repository_ctx.which("clang")
    if not clang_bin_path:
        fail("ERROR! Clang is not detected")
    clang_tidy_bin_path = repository_ctx.which("clang-tidy")
    if not clang_tidy_bin_path:
        fail("ERROR! Clang-tidy is not detected")

    defs = "CODECHECKER_BIN_PATH = '{}'\n".format(codechecker_bin_path)
    defs += "CLANG_BIN_PATH = '{}'\n".format(clang_bin_path)
    defs += "CLANG_TIDY_BIN_PATH = '{}'\n".format(clang_tidy_bin_path)
    defs += "BAZEL_VERSION = '{}'\n".format(native.bazel_version)
    defs += "CODECHECKER_VERSION = '{}'\n".format(codechecker_version)
    defs += "CODECHECKER_FALLBACK_PATH = '{}'\n".format(
        repository_ctx.attr.fallback_path,
    )
    repository_ctx.file(
        repository_ctx.path("defs.bzl"),
        content = defs,
        executable = False,
    )

    repository_ctx.symlink(codechecker_bin_path, "codechecker_bin")
    repository_ctx.symlink(clang_bin_path, "clang_bin")
    repository_ctx.symlink(clang_tidy_bin_path, "clang_tidy_bin")

    repository_ctx.file(
        repository_ctx.path("BUILD"),
        content = """
filegroup(
    name = "CodeChecker",
    srcs = ["codechecker_bin"],
    visibility = ["//visibility:public"],
)
filegroup(
    name = "clang",
    srcs = ["clang_bin"],
    visibility = ["//visibility:public"],
)
filegroup(
    name = "clang_tidy",
    srcs = ["clang_tidy_bin"],
    visibility = ["//visibility:public"],
)
        """,
        executable = False,
    )

default_codechecker_tools = repository_rule(
    attrs = {
        "fallback_path": attr.string(
            default = "/bin",
            doc = "PATH written into the environment when it has none. The " +
                  "analysis uses tools from outside of Bazel, so it cannot " +
                  "run without a PATH. Until the tools are hermetic this " +
                  "lets the rule take them from PATH as a temporary measure.",
        ),
    },
    local = True,
    doc = "Generate repository for default CodeChecker tools",
    implementation = _codechecker_local_repository_impl,
)

# Tag class letting the root module configure the fallback PATH in MODULE.bazel:
#
#     codechecker_extension = use_extension(
#         "@rules_codechecker//src:tools.bzl",
#         "module_register_default_codechecker_tools",
#     )
#     codechecker_extension.fallback_path(path = "/your/path")
_fallback_path_tag = tag_class(
    attrs = {
        "path": attr.string(
            default = "/bin",
            doc = "PATH written into the environment when it has none.",
        ),
    },
)

def register_default_codechecker_tools(module_ctx):
    """Create the default CodeChecker tools repository.

    The root module may set the fallback PATH with the fallback_path tag:
    the last value wins, so the root module always overrides dependencies.

    Args:
        module_ctx: The module extension context.
    """
    fallback_path = "/bin"
    for mod in module_ctx.modules:
        for tag in mod.tags.fallback_path:
            fallback_path = tag.path
    default_codechecker_tools(
        name = "default_codechecker_tools",
        fallback_path = fallback_path,
    )

# Define the extension here
module_register_default_codechecker_tools = module_extension(
    implementation = register_default_codechecker_tools,
    tag_classes = {
        "fallback_path": _fallback_path_tag,
    },
)
