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

load("@rules_python//python:py_test.bzl", "py_test")

exports_files(["requirements.txt"])

# The whole repository is checked from the workspace file.
# Pycodestyle comes from PyPI, see MODULE.bazel.
py_test(
    name = "pycodestyle",
    size = "medium",
    srcs = ["run_pycodestyle.py"],
    args = [
        "$(rootpath //:MODULE.bazel)",
        "--exclude '.svn','CVS','.bzr','.hg','.git','__pycache__','.tox','.ci'",
        "--show-source",
    ],
    data = [
        "//:MODULE.bazel",
    ],
    local = True,
    main = "run_pycodestyle.py",
    tags = [
        "external",
        "pycodestyle",
    ],
    deps = ["@pycodestyle_deps//pycodestyle"],
)
