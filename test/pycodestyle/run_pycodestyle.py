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
    """Run pycodestyle_test with the configuration of this package"""
    if len(sys.argv) < 2:
        print("Usage: pycodestyle_test.py <workspace file> [pylint options]")
        sys.exit(1)
    workspace= sys.argv[1]
    if not os.path.exists(workspace):
        print(f"Workspace file is not in the runfiles: {workspace}")
        sys.exit(1)
    root = os.path.dirname(os.path.realpath(workspace))
    print("Running Pycodestyle")
    print(f"Repository: {root}")
    #TODO
    #Either remove parse_argv and #args in BUILD.bzl
    #or the commented section
    style = pycodestyle.StyleGuide(
            parse_argv=True
            #exclude=[
            #         '.svn', 'CVS', '.bzr', '.hg',
            #         '.git', '__pycache__', '.tox', '.ci'
            #        ],
            #show_source=True
            )
    style.input_dir(root)


if __name__ == "__main__":
    main()
