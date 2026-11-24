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
Analysis test verifying that codechecker_toolchain propagates the runfiles of
its tool targets (including data dependencies) into the `runfiles` of
CodeCheckerInfo.

The test wires mock executable tools (one with a data dependency) through
codechecker_toolchain and asserts the tool executables and their data files
appear in the runfiles the toolchain hands to the analysis actions.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

# ---------------------------------------------------------------------------
# Subject rule: reads CodeCheckerInfo from a codechecker_toolchain target
# and re-exports runfiles basenames for inspection by the analysis test.
# ---------------------------------------------------------------------------

_RunfilesInfo = provider(
    doc = "Re-exports toolchain runfiles for test inspection.",
    fields = {
        "basenames": "Sorted list of basenames of files in the runfiles.",
        "has_runfiles": "Whether the toolchain has a runfiles field.",
    },
)

def _subject_impl(ctx):
    tc_info = ctx.attr.toolchain[platform_common.ToolchainInfo]
    info = tc_info.codecheckerinfo

    # CodeCheckerInfo.runfiles is a list the analysis rules spread into the
    # `tools` of ctx.actions.run: a FilesToRunProvider (the CodeChecker
    # launcher) and a depset carrying every tool file. Collect the basenames
    # of both to assert the tools and their data deps are propagated.
    files = []
    for entry in info.runfiles:
        if type(entry) == "depset":
            files += entry.to_list()
        else:
            files.append(entry.executable)
    basenames = sorted([f.basename for f in files])

    return [_RunfilesInfo(basenames = basenames)]

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

    # helper_data.txt is declared as data dep of the mock codechecker tool.
    asserts.true(
        env,
        "helper_data.txt" in info.basenames,
        "Expected helper_data.txt (data dep of mock tool) in runfiles, " +
        "got: %s" % info.basenames,
    )

    # The mock executables themselves.
    asserts.true(
        env,
        "mock_codechecker.sh" in info.basenames,
        "Expected mock_codechecker.sh in runfiles, got: %s" % info.basenames,
    )

    asserts.true(
        env,
        "mock_clang.sh" in info.basenames,
        "Expected mock_clang.sh in runfiles, got: %s" % info.basenames,
    )

    asserts.true(
        env,
        "mock_clang_tidy.sh" in info.basenames,
        "Expected mock_clang_tidy.sh in runfiles, got: %s" % info.basenames,
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
