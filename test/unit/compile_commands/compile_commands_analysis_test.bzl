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
Analysis-phase tests for compile_commands.bzl.

Tests the following functions indirectly via compile_commands_aspect:
  - collect_headers
  - get_sources
  - get_compile_flags
  - _cc_compiler_info
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load(
    "//src:compile_commands.bzl",
    "SourceFilesInfo",
    "compile_commands_aspect",
)

# =============================================================================
# Helpers
# =============================================================================

def _get_header_basenames(source_files_info):
    """Flatten SourceFilesInfo.headers into a list of basename strings."""
    basenames = []
    for h in source_files_info.headers.to_list():
        if hasattr(h, "basename"):
            basenames.append(h.basename)
        elif hasattr(h, "to_list"):
            for f in h.to_list():
                if hasattr(f, "basename"):
                    basenames.append(f.basename)
    return basenames

def _get_compile_commands(source_files_info):
    """Extract command strings from SourceFilesInfo.compilation_db."""
    return [entry.command for entry in source_files_info.compilation_db.to_list()]

def _get_source_basenames(source_files_info):
    """Extract basenames from SourceFilesInfo.transitive_source_files."""
    return [f.basename for f in source_files_info.transitive_source_files.to_list()]

# =============================================================================
# collect_headers
# =============================================================================

def _collect_headers_direct_test_impl(ctx):
    """Direct hdrs are collected."""
    env = analysistest.begin(ctx)
    header_basenames = _get_header_basenames(analysistest.target_under_test(env)[SourceFilesInfo])

    asserts.true(
        env,
        "foo.h" in header_basenames,
        "collect_headers should find foo.h, got: %s" % header_basenames,
    )

    return analysistest.end(env)

collect_headers_direct_test = analysistest.make(
    _collect_headers_direct_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

def _collect_headers_transitive_deps_test_impl(ctx):
    """Headers from deps are included transitively."""
    env = analysistest.begin(ctx)
    header_basenames = _get_header_basenames(analysistest.target_under_test(env)[SourceFilesInfo])

    asserts.true(
        env,
        "foo.h" in header_basenames,
        "Should find direct foo.h, got: %s" % header_basenames,
    )
    asserts.true(
        env,
        "bar.h" in header_basenames,
        "Should find transitive bar.h from deps, got: %s" % header_basenames,
    )

    return analysistest.end(env)

collect_headers_transitive_deps_test = analysistest.make(
    _collect_headers_transitive_deps_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

def _collect_headers_implementation_deps_test_impl(ctx):
    """Headers from implementation_deps are included."""
    env = analysistest.begin(ctx)
    header_basenames = _get_header_basenames(analysistest.target_under_test(env)[SourceFilesInfo])

    asserts.true(
        env,
        "foo.h" in header_basenames,
        "Should find direct foo.h, got: %s" % header_basenames,
    )
    asserts.true(
        env,
        "bar.h" in header_basenames,
        "Should find bar.h from implementation_deps, got: %s" % header_basenames,
    )

    return analysistest.end(env)

collect_headers_implementation_deps_test = analysistest.make(
    _collect_headers_implementation_deps_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

def _collect_headers_no_hdrs_test_impl(ctx):
    """Target with no hdrs produces no custom headers."""
    env = analysistest.begin(ctx)
    header_basenames = _get_header_basenames(analysistest.target_under_test(env)[SourceFilesInfo])

    asserts.false(
        env,
        "foo.h" in header_basenames,
        "Should not contain foo.h, got: %s" % header_basenames,
    )
    asserts.false(
        env,
        "bar.h" in header_basenames,
        "Should not contain bar.h, got: %s" % header_basenames,
    )

    return analysistest.end(env)

collect_headers_no_hdrs_test = analysistest.make(
    _collect_headers_no_hdrs_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

# =============================================================================
# get_sources
# =============================================================================

def _get_sources_srcs_and_hdrs_test_impl(ctx):
    """Both srcs and hdrs are collected."""
    env = analysistest.begin(ctx)
    basenames = _get_source_basenames(analysistest.target_under_test(env)[SourceFilesInfo])

    asserts.true(
        env,
        "foo.cc" in basenames,
        "Should collect foo.cc from srcs, got: %s" % basenames,
    )
    asserts.true(
        env,
        "foo.h" in basenames,
        "Should collect foo.h from hdrs, got: %s" % basenames,
    )

    return analysistest.end(env)

get_sources_srcs_and_hdrs_test = analysistest.make(
    _get_sources_srcs_and_hdrs_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

def _get_sources_only_srcs_test_impl(ctx):
    """Only srcs collected when no hdrs defined."""
    env = analysistest.begin(ctx)
    basenames = _get_source_basenames(analysistest.target_under_test(env)[SourceFilesInfo])

    asserts.true(
        env,
        "foo.cc" in basenames,
        "Should collect foo.cc, got: %s" % basenames,
    )
    asserts.false(
        env,
        "foo.h" in basenames,
        "Should not collect foo.h when not in hdrs, got: %s" % basenames,
    )

    return analysistest.end(env)

get_sources_only_srcs_test = analysistest.make(
    _get_sources_only_srcs_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

def _get_sources_transitive_test_impl(ctx):
    """Sources from deps are accumulated transitively."""
    env = analysistest.begin(ctx)
    basenames = _get_source_basenames(analysistest.target_under_test(env)[SourceFilesInfo])

    asserts.true(
        env,
        "foo.cc" in basenames,
        "Should collect foo.cc, got: %s" % basenames,
    )
    asserts.true(
        env,
        "bar.cc" in basenames,
        "Should collect bar.cc from dep, got: %s" % basenames,
    )
    asserts.true(
        env,
        "bar.h" in basenames,
        "Should collect bar.h from dep's hdrs, got: %s" % basenames,
    )

    return analysistest.end(env)

get_sources_transitive_test = analysistest.make(
    _get_sources_transitive_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

def _get_sources_implementation_deps_test_impl(ctx):
    """Sources from implementation_deps are accumulated."""
    env = analysistest.begin(ctx)
    basenames = _get_source_basenames(analysistest.target_under_test(env)[SourceFilesInfo])

    asserts.true(
        env,
        "foo.cc" in basenames,
        "Should collect foo.cc, got: %s" % basenames,
    )
    asserts.true(
        env,
        "bar.cc" in basenames,
        "Should collect bar.cc from implementation_deps, got: %s" % basenames,
    )
    asserts.true(
        env,
        "bar.h" in basenames,
        "Should collect bar.h from implementation_deps' hdrs, got: %s" % basenames,
    )

    return analysistest.end(env)

get_sources_implementation_deps_test = analysistest.make(
    _get_sources_implementation_deps_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

# =============================================================================
# get_compile_flags
# =============================================================================

def _get_compile_flags_defines_test_impl(ctx):
    """defines appear as -D in the compile command."""
    env = analysistest.begin(ctx)
    commands = _get_compile_commands(analysistest.target_under_test(env)[SourceFilesInfo])

    asserts.true(env, len(commands) > 0, "Should have at least one compile command")
    asserts.true(
        env,
        "MY_DEFINE" in commands[0],
        "Should contain define MY_DEFINE, got: %s" % commands[0],
    )

    return analysistest.end(env)

get_compile_flags_defines_test = analysistest.make(
    _get_compile_flags_defines_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

def _get_compile_flags_local_defines_test_impl(ctx):
    """local_defines appear as -D in the compile command."""
    env = analysistest.begin(ctx)
    commands = _get_compile_commands(analysistest.target_under_test(env)[SourceFilesInfo])

    asserts.true(env, len(commands) > 0, "Should have at least one compile command")
    asserts.true(
        env,
        "LOCAL_DEF" in commands[0],
        "Should contain local_define LOCAL_DEF, got: %s" % commands[0],
    )

    return analysistest.end(env)

get_compile_flags_local_defines_test = analysistest.make(
    _get_compile_flags_local_defines_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

def _get_compile_flags_includes_test_impl(ctx):
    """includes appear as -I in the compile command."""
    env = analysistest.begin(ctx)
    commands = _get_compile_commands(analysistest.target_under_test(env)[SourceFilesInfo])

    asserts.true(env, len(commands) > 0, "Should have at least one compile command")
    asserts.true(
        env,
        "my/include/path" in commands[0],
        "Should contain include path, got: %s" % commands[0],
    )

    return analysistest.end(env)

get_compile_flags_includes_test = analysistest.make(
    _get_compile_flags_includes_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

def _get_compile_flags_copts_test_impl(ctx):
    """copts are passed through to the compile command."""
    env = analysistest.begin(ctx)
    commands = _get_compile_commands(analysistest.target_under_test(env)[SourceFilesInfo])

    asserts.true(env, len(commands) > 0, "Should have at least one compile command")
    asserts.true(
        env,
        "-Wall" in commands[0],
        "Should contain -Wall, got: %s" % commands[0],
    )
    asserts.true(
        env,
        "-Wextra" in commands[0],
        "Should contain -Wextra, got: %s" % commands[0],
    )

    return analysistest.end(env)

get_compile_flags_copts_test = analysistest.make(
    _get_compile_flags_copts_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

def _get_compile_flags_dep_includes_test_impl(ctx):
    """includes from deps propagate to the compile command."""
    env = analysistest.begin(ctx)
    commands = _get_compile_commands(analysistest.target_under_test(env)[SourceFilesInfo])

    foo_commands = [c for c in commands if "foo.cc" in c]
    asserts.true(env, len(foo_commands) > 0, "Should have a command for foo.cc")
    asserts.true(
        env,
        "dep/include" in foo_commands[0],
        "Should contain dep's include path, got: %s" % foo_commands[0],
    )

    return analysistest.end(env)

get_compile_flags_dep_includes_test = analysistest.make(
    _get_compile_flags_dep_includes_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

def _get_compile_flags_no_duplicates_test_impl(ctx):
    """BUG: Compile flags should not contain duplicates.

    get_compile_flags may add the same include path multiple times — once
    from the target's own CcInfo compilation_context, and again when iterating
    over deps in SOURCE_ATTR. This test asserts the desired fixed behavior:
    no flag should appear more than once in a compile command.
    """
    env = analysistest.begin(ctx)
    commands = _get_compile_commands(analysistest.target_under_test(env)[SourceFilesInfo])

    foo_commands = [c for c in commands if "foo.cc" in c]
    asserts.true(env, len(foo_commands) > 0, "Should have a command for foo.cc")

    # Split command into flags and check for duplicates
    flags = foo_commands[0].split(" ")
    seen = []
    duplicates = []
    for f in flags:
        if f == "":
            continue
        if f in seen and f not in duplicates:
            duplicates.append(f)
        seen.append(f)
    asserts.true(
        env,
        len(duplicates) == 0,
        "Compile command should not have duplicate flags, found: %s" % duplicates,
    )

    return analysistest.end(env)

get_compile_flags_no_duplicates_test = analysistest.make(
    _get_compile_flags_no_duplicates_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

# =============================================================================
# _cc_compiler_info (C vs C++ language mode)
# =============================================================================

def _cc_compiler_info_cpp_language_mode_test_impl(ctx):
    """C++ files get -x c++ in the compile command."""
    env = analysistest.begin(ctx)
    commands = _get_compile_commands(analysistest.target_under_test(env)[SourceFilesInfo])

    cpp_commands = [c for c in commands if "foo.cc" in c]
    asserts.true(env, len(cpp_commands) > 0, "Should have a command for foo.cc")
    asserts.true(
        env,
        "-x c++" in cpp_commands[0],
        "C++ file should get -x c++, got: %s" % cpp_commands[0],
    )

    return analysistest.end(env)

cc_compiler_info_cpp_gets_language_mode_test = analysistest.make(
    _cc_compiler_info_cpp_language_mode_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

def _cc_compiler_info_c_no_language_mode_test_impl(ctx):
    """C files do NOT get -x c++ in the compile command."""
    env = analysistest.begin(ctx)
    commands = _get_compile_commands(analysistest.target_under_test(env)[SourceFilesInfo])

    c_commands = [c for c in commands if "bar.c" in c]
    asserts.true(env, len(c_commands) > 0, "Should have a command for bar.c")
    asserts.false(
        env,
        "-x c++" in c_commands[0],
        "C file should NOT get -x c++, got: %s" % c_commands[0],
    )

    return analysistest.end(env)

cc_compiler_info_c_no_language_mode_test = analysistest.make(
    _cc_compiler_info_c_no_language_mode_test_impl,
    extra_target_under_test_aspects = [compile_commands_aspect],
)

# =============================================================================
# Test suites
# =============================================================================

def collect_headers_test_suite(name):
    """Analysis tests for collect_headers.

    Args:
        name: the name prefix for the test suite.
    """
    collect_headers_direct_test(
        name = name + "_direct_test",
        target_under_test = ":" + name + "_foo",
    )
    collect_headers_transitive_deps_test(
        name = name + "_transitive_test",
        target_under_test = ":" + name + "_with_dep",
    )
    collect_headers_implementation_deps_test(
        name = name + "_impl_dep_test",
        target_under_test = ":" + name + "_with_impl_dep",
    )
    collect_headers_no_hdrs_test(
        name = name + "_no_hdrs_test",
        target_under_test = ":" + name + "_no_hdrs",
    )

    native.test_suite(
        name = name,
        tests = [
            ":" + name + "_direct_test",
            ":" + name + "_transitive_test",
            ":" + name + "_impl_dep_test",
            ":" + name + "_no_hdrs_test",
        ],
    )

def get_sources_test_suite(name):
    """Analysis tests for get_sources.

    Args:
        name: the name prefix for the test suite.
    """
    get_sources_srcs_and_hdrs_test(
        name = name + "_srcs_and_hdrs_test",
        target_under_test = ":collect_headers_tests_foo",
    )
    get_sources_only_srcs_test(
        name = name + "_only_srcs_test",
        target_under_test = ":collect_headers_tests_no_hdrs",
    )
    get_sources_transitive_test(
        name = name + "_transitive_test",
        target_under_test = ":collect_headers_tests_with_dep",
    )
    get_sources_implementation_deps_test(
        name = name + "_impl_deps_test",
        target_under_test = ":collect_headers_tests_with_impl_dep",
    )

    native.test_suite(
        name = name,
        tests = [
            ":" + name + "_srcs_and_hdrs_test",
            ":" + name + "_only_srcs_test",
            ":" + name + "_transitive_test",
            ":" + name + "_impl_deps_test",
        ],
    )

def get_compile_flags_test_suite(name):
    """Analysis tests for get_compile_flags.

    Args:
        name: the name prefix for the test suite.
    """
    get_compile_flags_defines_test(
        name = name + "_defines_test",
        target_under_test = ":" + name + "_with_defines",
    )
    get_compile_flags_local_defines_test(
        name = name + "_local_defines_test",
        target_under_test = ":" + name + "_with_local_defines",
    )
    get_compile_flags_includes_test(
        name = name + "_includes_test",
        target_under_test = ":" + name + "_with_includes",
    )
    get_compile_flags_copts_test(
        name = name + "_copts_test",
        target_under_test = ":" + name + "_with_copts",
    )
    get_compile_flags_dep_includes_test(
        name = name + "_dep_includes_test",
        target_under_test = ":" + name + "_with_dep_includes",
    )

    native.test_suite(
        name = name,
        tests = [
            ":" + name + "_defines_test",
            ":" + name + "_local_defines_test",
            ":" + name + "_includes_test",
            ":" + name + "_copts_test",
            ":" + name + "_dep_includes_test",
        ],
    )

def cc_compiler_info_test_suite(name):
    """Analysis tests for _cc_compiler_info (C vs C++ language mode).

    Args:
        name: the name prefix for the test suite.
    """
    cc_compiler_info_cpp_gets_language_mode_test(
        name = name + "_cpp_language_mode_test",
        target_under_test = ":" + name + "_cpp_target",
    )
    cc_compiler_info_c_no_language_mode_test(
        name = name + "_c_no_language_mode_test",
        target_under_test = ":" + name + "_c_target",
    )

    native.test_suite(
        name = name,
        tests = [
            ":" + name + "_cpp_language_mode_test",
            ":" + name + "_c_no_language_mode_test",
        ],
    )
