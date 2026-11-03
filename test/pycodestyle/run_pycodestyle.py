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
Run pycodestyle on the Python files of the repository.
"""

import os
import sys

import pycodestyle


def main():
    """Run pycodestyle"""
    if len(sys.argv) < 2:
        print("Usage: run_pycodestyle.py <workspace file> pycodestyle_args")
        sys.exit(1)
    workspace = sys.argv[1]
    if not os.path.exists(workspace):
        print(f"Workspace file is not in the runfiles: {workspace}")
        sys.exit(1)
    root = os.path.dirname(os.path.realpath(workspace))
    print(sys.argv)
    print("Running Pycodestyle")
    print(f"Repository: {root}")
    style = pycodestyle.StyleGuide(
            parse_argv=True,
            )
    style.input_dir(root)


if __name__ == "__main__":
    main()
