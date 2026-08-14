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
load("@buildifier_prebuilt//:rules.bzl", "buildifier_test")

# Patches applied to buildifier_prebuilt, see MODULE.bazel
exports_files([
    "prune.patch",
    "template.patch",
])

# The linter is declared here, and not in the root package, because
# buildifier_prebuilt is a dev dependency and therefore not visible to our
# consumers, while the root package has to stay loadable by them.
# The whole repository is still checked, no_sandbox and the workspace
# attribute make the test run from the repository root.
buildifier_test(
    name = "buildifier",
    exclude_patterns = [
        "./.ci/*",
        "./.git/*",
    ],
    lint_mode = "warn",
    lint_warnings = ["all"],
    mode = "diff",
    no_sandbox = True,
    verbose = True,
    workspace = "//:MODULE.bazel",
)
