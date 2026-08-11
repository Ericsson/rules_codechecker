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
Unit tests for compile_commands.bzl pure Starlark functions.

Tests the following functions directly (no analysis phase needed):
  - compile_commands_json
  - check_source_files
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load(
    "//src:compile_commands.bzl",
    "check_source_files",
    "compile_commands_json",
)

# =============================================================================
# compile_commands_json
# =============================================================================

def _compile_commands_json_single_entry_test_impl(ctx):
    """Single entry produces valid JSON array."""
    env = unittest.begin(ctx)

    compilation_db = [struct(
        file = "src/main.cc",
        command = "clang++ -c src/main.cc",
        directory = ".",
    )]

    result = compile_commands_json(compilation_db)

    asserts.true(env, result.startswith("[\n"), "Should start with '[\\n'")
    asserts.true(env, result.endswith("]\n"), "Should end with ']\\n'")
    asserts.true(env, "src/main.cc" in result, "Should contain file path")
    asserts.true(env, "clang++ -c src/main.cc" in result, "Should contain command")

    return unittest.end(env)

compile_commands_json_single_entry_test = unittest.make(
    _compile_commands_json_single_entry_test_impl,
)

def _compile_commands_json_multiple_entries_test_impl(ctx):
    """Multiple entries are comma-separated without trailing comma."""
    env = unittest.begin(ctx)

    compilation_db = [
        struct(file = "src/main.cc", command = "clang++ -c src/main.cc", directory = "."),
        struct(file = "src/util.c", command = "clang -c src/util.c", directory = "."),
        struct(file = "src/lib.cc", command = "clang++ -c src/lib.cc", directory = "/ws"),
    ]

    result = compile_commands_json(compilation_db)

    asserts.true(env, "src/main.cc" in result, "Should contain first file")
    asserts.true(env, "src/util.c" in result, "Should contain second file")
    asserts.true(env, "src/lib.cc" in result, "Should contain third file")
    asserts.true(env, ",\n" in result, "Entries should be comma-separated")
    asserts.false(env, ",\n]\n" in result, "Should not have trailing comma")

    return unittest.end(env)

compile_commands_json_multiple_entries_test = unittest.make(
    _compile_commands_json_multiple_entries_test_impl,
)

def _compile_commands_json_empty_list_test_impl(ctx):
    """Empty list produces empty JSON array."""
    env = unittest.begin(ctx)

    result = compile_commands_json([])

    asserts.equals(env, "[\n]\n", result, "Empty list should produce empty JSON array")

    return unittest.end(env)

compile_commands_json_empty_list_test = unittest.make(
    _compile_commands_json_empty_list_test_impl,
)

# =============================================================================
# check_source_files
# =============================================================================

def _check_source_files_all_present_test_impl(ctx):
    """All compilation DB files found in source list → no error."""
    env = unittest.begin(ctx)

    source_files = [struct(path = "src/main.cc"), struct(path = "src/util.c")]
    compilation_db = [struct(file = "src/main.cc"), struct(file = "src/util.c")]

    result = check_source_files(source_files, compilation_db)
    asserts.equals(env, None, result, "Should return None when all files present")

    return unittest.end(env)

check_source_files_all_present_test = unittest.make(
    _check_source_files_all_present_test_impl,
)

def _check_source_files_missing_file_test_impl(ctx):
    """Missing file in source list → error mentioning the file."""
    env = unittest.begin(ctx)

    source_files = [struct(path = "src/main.cc")]
    compilation_db = [struct(file = "src/main.cc"), struct(file = "src/missing.cc")]

    result = check_source_files(source_files, compilation_db)
    asserts.true(env, result != None, "Should return an error message")
    asserts.true(env, "src/missing.cc" in result, "Error should mention the missing file")
    asserts.true(env, "Not available" in result, "Error should indicate file is not available")

    return unittest.end(env)

check_source_files_missing_file_test = unittest.make(
    _check_source_files_missing_file_test_impl,
)

def _check_source_files_empty_sources_test_impl(ctx):
    """Empty source list with non-empty db → error."""
    env = unittest.begin(ctx)

    source_files = []
    compilation_db = [struct(file = "src/main.cc")]

    result = check_source_files(source_files, compilation_db)
    asserts.true(env, result != None, "Should return error when sources empty but db has entries")
    asserts.true(env, "src/main.cc" in result, "Error should mention the missing file")

    return unittest.end(env)

check_source_files_empty_sources_test = unittest.make(
    _check_source_files_empty_sources_test_impl,
)

def _check_source_files_empty_db_test_impl(ctx):
    """Empty compilation database → no error."""
    env = unittest.begin(ctx)

    source_files = [struct(path = "src/main.cc")]
    compilation_db = []

    result = check_source_files(source_files, compilation_db)
    asserts.equals(env, None, result, "Should return None for empty compilation db")

    return unittest.end(env)

check_source_files_empty_db_test = unittest.make(
    _check_source_files_empty_db_test_impl,
)

# =============================================================================
# Test suite
# =============================================================================

def compile_commands_test_suite(name):
    """Unit test suite for compile_commands.bzl pure functions.

    Args:
        name: the name of the test suite target.
    """
    unittest.suite(
        name,
        compile_commands_json_single_entry_test,
        compile_commands_json_multiple_entries_test,
        compile_commands_json_empty_list_test,
        check_source_files_all_present_test,
        check_source_files_missing_file_test,
        check_source_files_empty_db_test,
        check_source_files_empty_sources_test,
    )
