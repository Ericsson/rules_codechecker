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
Analysis test verifying that codechecker_toolchain propagates data_runfiles
of its tool targets into the `runfiles` depset of CodeCheckerInfo.

The test wires mock executable tools (one with a data dependency) through
codechecker_toolchain and asserts the data files appear in the resulting
runfiles depset.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

# ---------------------------------------------------------------------------
# Subject rule: reads CodeCheckerInfo from a codechecker_toolchain target
# and re-exports runfiles basenames for inspection by the analysis test.
# ---------------------------------------------------------------------------

_RunfilesInfo = provider(
    doc = "Re-exports toolchain runfiles for test inspection.",
    fields = {
        "basenames": "Sorted list of basenames of files in the runfiles depset.",
        "has_runfiles": "Whether the toolchain has a runfiles field.",
    },
)

def _subject_impl(ctx):
    tc_info = ctx.attr.toolchain[platform_common.ToolchainInfo]
    info = tc_info.codecheckerinfo

    # TODO: remove hasattr guard once the fix is applied.
    if hasattr(info, "runfiles"):
        basenames = sorted([f.basename for f in info.runfiles.to_list()])
        has_runfiles = True
    else:
        basenames = []
        has_runfiles = False

    return [_RunfilesInfo(basenames = basenames, has_runfiles = has_runfiles)]

subject_rule = rule(
    implementation = _subject_impl,
    attrs = {
        "toolchain": attr.label(mandatory = True),
    },
)

# ---------------------------------------------------------------------------
# Test: data deps of tool targets appear in toolchain runfiles
# ---------------------------------------------------------------------------

def _test_data_deps_in_runfiles_impl(ctx):
    env = analysistest.begin(ctx)

    target = analysistest.target_under_test(env)
    info = target[_RunfilesInfo]

    # TODO: change asserts.false to asserts.true once the fix is applied.
    # Remove NOT from fail message
    asserts.false(
        env,
        info.has_runfiles,
        "Expected CodeCheckerInfo to NOT have runfiles.",
    )

    # helper_data.txt is declared as data dep of the mock codechecker tool.
    # TODO: change asserts.false to asserts.true once the fix is applied.
    # Remove NOT from fail message
    asserts.false(
        env,
        "helper_data.txt" in info.basenames,
        "NOT Expected helper_data.txt (data dep of mock tool) in runfiles, " +
        "got: %s" % info.basenames,
    )

    # The mock executables themselves.
    # TODO: change asserts.false to asserts.true once the fix is applied.
    # Remove NOT from fail message
    asserts.false(
        env,
        "mock_codechecker.sh" in info.basenames,
        "NOT Expected mock_codechecker.sh in runfiles, got: %s" % info.basenames,
    )

    # TODO: change asserts.false to asserts.true once the fix is applied.
    # Remove NOT from fail message
    asserts.false(
        env,
        "mock_clang.sh" in info.basenames,
        "NOT Expected mock_clang.sh in runfiles, got: %s" % info.basenames,
    )

    # TODO: change asserts.false to asserts.true once the fix is applied.
    # Remove NOT from fail message
    asserts.false(
        env,
        "mock_clang_tidy.sh" in info.basenames,
        "NOT Expected mock_clang_tidy.sh in runfiles, got: %s" % info.basenames,
    )

    return analysistest.end(env)

data_deps_in_runfiles_test = analysistest.make(
    _test_data_deps_in_runfiles_impl,
)

# ---------------------------------------------------------------------------
# Test suite
# ---------------------------------------------------------------------------

def runfiles_test_suite(name):
    """Instantiates targets and test for toolchain runfiles propagation.

    Args:
        name: Name prefix for the generated targets.
    """
    subject_rule(
        name = name + "_subject",
        toolchain = name + "_mock_toolchain",
        tags = ["manual"],
    )

    data_deps_in_runfiles_test(
        name = name + "_data_deps_in_runfiles_test",
        target_under_test = name + "_subject",
    )

    native.test_suite(
        name = name,
        tests = [
            name + "_data_deps_in_runfiles_test",
        ],
    )
