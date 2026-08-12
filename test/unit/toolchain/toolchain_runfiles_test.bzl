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
# A minimal executable rule with data deps, used as a mock tool.
# Needed because codechecker_toolchain requires allow_single_file = True
# which is incompatible with sh_binary.
# ---------------------------------------------------------------------------

def _mock_executable_impl(ctx):
    out = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.symlink(output = out, target_file = ctx.file.src, is_executable = True)
    runfiles = ctx.runfiles(files = [out] + ctx.files.data)
    return [DefaultInfo(
        executable = out,
        files = depset([out]),
        data_runfiles = runfiles,
    )]

mock_executable = rule(
    implementation = _mock_executable_impl,
    attrs = {
        "data": attr.label_list(allow_files = True),
        "src": attr.label(mandatory = True, allow_single_file = True),
    },
    executable = True,
)

# ---------------------------------------------------------------------------
# Subject rule: reads CodeCheckerInfo from a codechecker_toolchain target
# and re-exports runfiles basenames for inspection by the analysis test.
# ---------------------------------------------------------------------------

_RunfilesInfo = provider(
    doc = "Re-exports toolchain runfiles for test inspection.",
    fields = {
        "basenames": "Sorted list of basenames of files in the runfiles depset.",
    },
)

def _subject_impl(ctx):
    tc_info = ctx.attr.toolchain[platform_common.ToolchainInfo]
    info = tc_info.codecheckerinfo
    basenames = sorted([f.basename for f in info.runfiles.to_list()])
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

    # The mock executables themselves should also be present.
    asserts.true(
        env,
        "mock_codechecker" in info.basenames,
        "Expected mock_codechecker in runfiles, got: %s" % info.basenames,
    )
    asserts.true(
        env,
        "mock_clang" in info.basenames,
        "Expected mock_clang in runfiles, got: %s" % info.basenames,
    )
    asserts.true(
        env,
        "mock_clang_tidy" in info.basenames,
        "Expected mock_clang_tidy in runfiles, got: %s" % info.basenames,
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
