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

# Hermetic, pip-provided CodeChecker.
#
# The CodeChecker executable is fetched from PyPI by the pip extension in
# MODULE.bazel (hub name: codechecker_deps) and exposed here as a console
# script binary, so the default toolchain no longer needs CodeChecker on PATH.

load("@rules_python//python:pip.bzl", "compile_pip_requirements")
load(
    "@rules_python//python/entry_points:py_console_script_binary.bzl",
    "py_console_script_binary",
)

# Regenerate the pinned requirements.txt closure from requirements.in with:
#   bazel run //src/codechecker_pip:requirements.update
# and verify it with:
#   bazel test //src/codechecker_pip:requirements_test
compile_pip_requirements(
    name = "requirements",
    src = "requirements.in",
    requirements_txt = "requirements.txt",
)

# The CodeChecker console script, provided hermetically by pip.
# This is the executable the default toolchain resolves for CodeChecker.
#
# The wheel's data files (share/codechecker: config, ld_logger, analyzer
# configs ...) are added to the runfiles via the data dependency. The
# CodeChecker wrapper scripts (src/codechecker_script.py, src/per_file_script.py
# via src/common.py) locate them in the runfiles and export CC_BIN_DIR so
# CodeChecker finds its data files without any extra entry point.
py_console_script_binary(
    name = "CodeChecker",
    data = ["@codechecker_deps//codechecker:data"],
    pkg = "@codechecker_deps//codechecker",
    script = "CodeChecker",
    visibility = ["//visibility:public"],
)
