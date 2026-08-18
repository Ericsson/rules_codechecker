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
Provide a collection of functions used by multiple bzl files.
"""

load("@default_codechecker_tools//:defs.bzl", "BAZEL_VERSION")

SOURCE_ATTR = [
    "srcs",
    "deps",
    "data",
    "exports",
    "implementation_deps",
]

def version_specific_attributes():
    """
    Returns a map of Bazel version specific attributes

    For instance:
    In older Bazel versions (e.g. 6) rulesets using transitions
    must have the attribute _whitelist_function_transition.
    In newer versions (e.g. 7) this is an error.
    """
    if BAZEL_VERSION.split(".")[0] in "0123456":
        return ({"_whitelist_function_transition": attr.label(
            default = "@bazel_tools//tools/whitelists/function_transition_whitelist",
            doc = "needed for transitions",
        )})
    return {}

def resolve_toolchain_info(ctx):
    """Resolve CodeCheckerInfo from explicit attribute or Bazel toolchain resolution.

    If the user specified a `toolchain` attribute pointing to a
    `toolchain()` target, use its provider directly. Otherwise,
    fall back to Bazel's standard toolchain resolution.

    Args:
        ctx: The rule context. Must have a `toolchain` attribute
             and the `//src:toolchain_type` toolchain declared.
    Returns:
        A CodeCheckerInfo provider instance.
    """
    if ctx.attr.toolchain:
        return ctx.attr.toolchain[platform_common.ToolchainInfo].codecheckerinfo

    # TODO: Consider using aliases so we don't have to type //src: everywhere.
    return ctx.toolchains["//:toolchain_type"].codecheckerinfo

def warning(ctx, msg):
    """
    Prints message if the debug tag is enabled.

    NOTE: "debug" in tags works only for rules, not aspects
    """
    if hasattr(ctx.attr, "tags") and "debug" in ctx.attr.tags:
        # buildifier: disable=print
        print(msg)
