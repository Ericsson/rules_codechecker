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
Analysis test for transitive sources of an aggregating target.

A source reached through deps must be analyzed with its own target's
compilation arguments, not the aggregating target's.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _source_arguments(env, source):
    """Return the arguments of the analyzer action for a given source"""
    for action in analysistest.target_actions(env):
        if action.mnemonic not in ["ClangTidy", "ClangAnalyze"]:
            continue
        if any([argument.endswith(source) for argument in action.argv]):
            return action.argv
    return []

def _transitive_arguments_test_impl(ctx):
    """A transitive source keeps the copts of its own target"""
    env = analysistest.begin(ctx)
    arguments = _source_arguments(env, "lib.cc")

    asserts.true(
        env,
        len(arguments) > 0,
        "The transitive source lib.cc is not analyzed",
    )
    asserts.true(
        env,
        "-DFROM_LIB=1" in arguments,
        "lib.cc must be analyzed with its own copts: %s" % arguments,
    )

    return analysistest.end(env)

transitive_arguments_test = analysistest.make(_transitive_arguments_test_impl)
