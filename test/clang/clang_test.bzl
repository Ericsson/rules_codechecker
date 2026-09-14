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
Analysis tests for the command line of the clang rules.

The analysis is invoked with the flags of the toolchain and of the build. The
flags are asserted at analysis time, a finding of the analyzer would fail the
build, therefore it cannot be a passing test yet.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _clang_arguments(env):
    """Return the arguments of the analyzer actions"""
    arguments = []
    for action in analysistest.target_actions(env):
        if action.mnemonic in ["ClangTidy", "ClangAnalyze"]:
            arguments += action.argv
    return arguments

def _values_of(arguments, option):
    """Return the values following an option, e.g. the paths of -isystem"""
    return [
        arguments[index + 1]
        for index, argument in enumerate(arguments)
        if argument == option and index + 1 < len(arguments)
    ]

def _builtin_includes_test_impl(ctx):
    """The builtin include directories of the toolchain are passed"""
    env = analysistest.begin(ctx)
    includes = _values_of(_clang_arguments(env), "-isystem")

    asserts.true(
        env,
        len(includes) > 0,
        "The builtin include directories of the toolchain are missing",
    )

    # Clang cannot parse the headers of GCC, they are left out
    gcc_includes = [include for include in includes if "/gcc/" in include]
    asserts.true(
        env,
        len(gcc_includes) == 0,
        "The GCC include directories should be left out: %s" % gcc_includes,
    )

    return analysistest.end(env)

builtin_includes_test = analysistest.make(_builtin_includes_test_impl)

def _copts_test_impl(ctx):
    """The --copt options of the build are passed for every language"""
    env = analysistest.begin(ctx)
    arguments = _clang_arguments(env)

    asserts.true(
        env,
        "-DFROM_COPT=1" in arguments,
        "The --copt option is missing: %s" % arguments,
    )

    return analysistest.end(env)

copts_test = analysistest.make(
    _copts_test_impl,
    config_settings = {
        "//command_line_option:copt": ["-DFROM_COPT=1"],
    },
)

def _cxxopts_test_impl(ctx):
    """The --cxxopt options of the build are passed for C++ sources"""
    env = analysistest.begin(ctx)
    arguments = _clang_arguments(env)

    asserts.true(
        env,
        "-DFROM_CXXOPT=1" in arguments,
        "The --cxxopt option is missing: %s" % arguments,
    )

    return analysistest.end(env)

cxxopts_test = analysistest.make(
    _cxxopts_test_impl,
    config_settings = {
        "//command_line_option:cxxopt": ["-DFROM_CXXOPT=1"],
    },
)

def _cxxopts_not_in_c_test_impl(ctx):
    """The --cxxopt options of the build are not passed for C sources"""
    env = analysistest.begin(ctx)
    arguments = _clang_arguments(env)

    asserts.true(
        env,
        "-DFROM_CXXOPT=1" not in arguments,
        "A C source must not be analyzed with a C++ option: %s" % arguments,
    )

    return analysistest.end(env)

cxxopts_not_in_c_test = analysistest.make(
    _cxxopts_not_in_c_test_impl,
    config_settings = {
        "//command_line_option:cxxopt": ["-DFROM_CXXOPT=1"],
    },
)

def _conlyopts_test_impl(ctx):
    """The --conlyopt options of the build are passed for C sources"""
    env = analysistest.begin(ctx)
    arguments = _clang_arguments(env)

    asserts.true(
        env,
        "-DFROM_CONLYOPT=1" in arguments,
        "The --conlyopt option is missing: %s" % arguments,
    )

    return analysistest.end(env)

conlyopts_test = analysistest.make(
    _conlyopts_test_impl,
    config_settings = {
        "//command_line_option:conlyopt": ["-DFROM_CONLYOPT=1"],
    },
)
