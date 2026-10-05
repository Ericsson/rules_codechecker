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
Shared helpers for the parse and store verification scripts.
"""

import os
import subprocess
import sys

# Basename of the directory holding the analyzer result files
REPORT_DIR_NAME = "data"


def resolve_report_data(paths: list[str]) -> str:
    """Return the report directory that CodeChecker parse/store consume.

    Bazel passes every output of the analysis target via $(rootpaths). The
    reports live in a directory named "data"; depending on the rule it is
    either passed directly as a directory artifact (monolithic) or implied by
    the individual report files inside it (per-file).
    """
    for path in paths:
        # Monolithic passes the "codechecker-files" directory artifact; its
        # reports live in the "data" subdirectory.
        if os.path.isdir(os.path.join(path, REPORT_DIR_NAME)):
            return os.path.join(path, REPORT_DIR_NAME)
        # Per-file passes individual report files, e.g. .../data/foo.plist;
        # derive the enclosing "data" directory from them.
        parent = os.path.dirname(path)
        if os.path.basename(parent) == REPORT_DIR_NAME and os.path.isdir(
            parent
        ):
            return parent

    print(f"FAILED: no {REPORT_DIR_NAME} report directory in paths: {paths}")
    sys.exit(1)


def run_codechecker(arguments: list[str]) -> tuple[int, str, str]:
    """Run a CodeChecker command and return (exit_code, stdout, stderr)."""
    command = ["CodeChecker"] + arguments
    print(f"Running: {' '.join(command)}")
    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
        check=False,
    )
    return result.returncode, result.stdout, result.stderr
