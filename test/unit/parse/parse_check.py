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
Self-contained parse verification script for Bazel py_test targets.

Runs "CodeChecker parse" on the report files produced by a codechecker_test
target that is supplied as a data dependency. Two modes are supported:

    parse       Parse the results and assert a bug is reported.
                CodeChecker parse exits with code 2 when it finds a report,
                and 0 when it finds none. The analyzed source contains a bug,
                so exit code 2 is expected.

    parse_html  Export the results as an HTML report into a temporary
                directory and assert that a non-empty index.html is produced.

The report directory is passed in by Bazel via $(rootpaths), so no path is
hard-coded and no nested Bazel invocation is required.

Usage:
    python parse_check.py --mode parse <rootpaths...>
    python parse_check.py --mode parse_html <rootpaths...>
"""

import argparse
import os
import subprocess
import sys
import tempfile

# Basename of the analysis output directory produced by codechecker_test.
REPORT_DIR_NAME = "codechecker-files"


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Verify CodeChecker parse behavior."
    )
    parser.add_argument(
        "--mode",
        required=True,
        choices=["parse", "parse_html"],
        help="Which parse check to run.",
    )
    parser.add_argument(
        "paths",
        nargs="+",
        help="Runfiles paths of the analysis target ($(rootpaths ...)); "
        "the report directory is selected from them.",
    )
    return parser.parse_args()


def resolve_report_data(paths: list[str]) -> str:
    """Return the data subdirectory that CodeChecker parse consumes.

    Bazel passes every output of the analysis target via $(rootpaths); the
    report directory is the one ending in "codechecker-files", and the plist
    reports live in its "data" subdirectory.
    """
    report_dirs = [p for p in paths if os.path.basename(p) == REPORT_DIR_NAME]
    if not report_dirs:
        print(f"FAILED: no {REPORT_DIR_NAME} directory in paths: {paths}")
        sys.exit(1)
    data_dir = os.path.join(report_dirs[0], "data")
    if not os.path.isdir(data_dir):
        print(f"FAILED: report data directory not found at {data_dir}")
        sys.exit(1)
    return data_dir


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


def check_parse(report_dir: str) -> int:
    """Parse the results and assert a bug is reported (exit code 2)."""
    ret, stdout, stderr = run_codechecker(["parse", report_dir])
    if ret != 2:
        print(
            f"FAILED: Expected CodeChecker parse to report a bug "
            f"(exit code 2), got {ret}"
        )
        print(f"stdout:\n{stdout}")
        print(f"stderr:\n{stderr}")
        return 1
    print("PASSED: CodeChecker parse reported a bug as expected.")
    return 0


def check_parse_html(report_dir: str) -> int:
    """Export an HTML report and assert a non-empty index.html is produced."""
    with tempfile.TemporaryDirectory() as html_dir:
        ret, stdout, stderr = run_codechecker(
            ["parse", report_dir, "--export", "html", "--output", html_dir]
        )
        # CodeChecker parse exits 2 when reports are found, 0 otherwise;
        # both indicate the export ran. Anything else is a real failure.
        if ret not in (0, 2):
            print(
                f"FAILED: CodeChecker parse --export html failed with "
                f"exit code {ret}"
            )
            print(f"stdout:\n{stdout}")
            print(f"stderr:\n{stderr}")
            return 1
        index_html = os.path.join(html_dir, "index.html")
        if not os.path.isfile(index_html):
            print(f"FAILED: HTML report not produced at {index_html}")
            print(f"stdout:\n{stdout}")
            print(f"stderr:\n{stderr}")
            return 1
        if os.path.getsize(index_html) == 0:
            print(f"FAILED: HTML report is empty at {index_html}")
            return 1
    print("PASSED: CodeChecker parse produced a non-empty HTML report.")
    return 0


def main() -> int:
    """Entry point."""
    args = parse_args()
    report_dir = resolve_report_data(args.paths)
    if args.mode == "parse":
        return check_parse(report_dir)
    return check_parse_html(report_dir)


if __name__ == "__main__":
    sys.exit(main())
