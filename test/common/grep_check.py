# Copyright 2023 Ericsson AB
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
Validates wether a list of patterns is found in a file

This test reads a file and asserts that all provided patterns
are present within its contents.

Intended to be used as the main of a py_test Bazel target.
"""

import argparse
import logging
import shlex
import subprocess
import sys


def parse_args() -> argparse.Namespace:
    """
    Parse command-line arguments.
    Returns:
        Parsed arguments containing the file path and list of patterns.
    """
    parser = argparse.ArgumentParser(
        description=(
            "Assert that all given patterns exist in the provided file."
        )
    )
    parser.add_argument(
        "--file",
        required=True,
        help="Path to the file to search within (e.g., a test log file).",
    )
    parser.add_argument(
        "--patterns",
        nargs="+",
        required=True,
        help="One or more patterns to assert are present in the file.",
    )
    return parser.parse_args()

def main() -> None:
    """Entry point for the pattern-matching test."""
    args = parse_args()
    with open(args.file, "r", encoding="utf-8") as f:
        content = f.read()

    all_passed = True
    for pattern in args.patterns:
        if pattern not in content:
            print(f"  [FAIL] Pattern missing: '{pattern}'")
            all_passed = False

    if not all_passed:
        print("\nOne or more patterns missing. Test FAILED.")
        sys.exit(1)


if __name__ == "__main__":
    main()
