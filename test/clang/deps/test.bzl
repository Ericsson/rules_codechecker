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

"""
Analysis tests for the include paths of the dependencies.

A source is analyzed with the include paths of its dependencies,
otherwise the analyzer does not find the headers.
A public dependency propagates its paths through CcInfo,
a private one in implementation_deps does not,
so they are collected from the attribute.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _clang_arguments(env):
    """Return the arguments of the analyzer actions"""
    arguments = []
    for action in analysistest.target_actions(env):
        if action.mnemonic in ["ClangTidy", "ClangAnalyze"]:
            arguments += action.argv
    return arguments

def _includes_path(arguments, path):
    """Check if a path is used as an include path

    The include options are passed as a single argument, e.g. "-isystem path",
    so the path is searched in the argument.
    """
    for argument in arguments:
        if path in argument and argument.startswith("-"):
            return True
    return False

def _public_dep_test_impl(ctx):
    """The include paths of a dependency in deps are passed"""
    env = analysistest.begin(ctx)
    arguments = _clang_arguments(env)

    asserts.true(
        env,
        _includes_path(arguments, "test/clang/deps/public"),
        "The include path of the public dependency is missing: %s" % arguments,
    )

    return analysistest.end(env)

public_dep_test = analysistest.make(_public_dep_test_impl)

def _private_dep_test_impl(ctx):
    """The include paths of a dependency in implementation_deps are passed"""
    env = analysistest.begin(ctx)
    arguments = _clang_arguments(env)

    asserts.true(
        env,
        _includes_path(arguments, "test/clang/deps/private"),
        "The include path of the private dependency is missing: %s" % arguments,
    )

    return analysistest.end(env)

private_dep_test = analysistest.make(_private_dep_test_impl)
