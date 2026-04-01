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
Rulesets for storing the results of codechecker on a codechecker server.
"""

def _get_plist_folder_path(ctx):
    """
    Determines the folder where the plist files of the analysis reside.
    """
    candidate = ctx.files.target[0]
    for file in ctx.files.target:
        # Only in monolithic rule
        if file.is_directory:
            return file.short_path
            # Assume all plist files are in the same folder in per_file rule

        elif file.basename.endswith(".plist"):
            candidate = file
    return "$(dirname {file})".format(file = candidate.short_path)

def _codechecker_store_impl(ctx):
    folder_path = _get_plist_folder_path(ctx)

    name = ctx.attr.analysis_name
    if name == "":
        name = ctx.attr.name

    ctx.actions.write(
        output = ctx.outputs.test_script,
        is_executable = True,
        content = """
            # We must override home to avoid writing outside the sandbox
            export HOME=$TEST_TMPDIR
            CodeChecker store {target_folder} --url {url} --name {name}
        """.format(
            target_folder = folder_path,
            url = ctx.attr.url,
            name = name,
        ),
    )

    run_files = [ctx.outputs.test_script] + ctx.files.target
    return [
        DefaultInfo(
            files = None,
            runfiles = ctx.runfiles(files = run_files),
            executable = ctx.outputs.test_script,
        ),
    ]

codechecker_store_test = rule(
    implementation = _codechecker_store_impl,
    attrs = {
        "analysis_name": attr.string(
            default = "",
            doc = "Name to store the run under the CodeChecker server. Defaults to the action name",
        ),
        "url": attr.string(
            default = "http://localhost:8001/Default",
            doc = "Url to the CodeChecker server. Defaults to http://localhost:8001/Default",
        ),
        "tag": attr.string(
            default = "",
            doc = "Tag to add to the analysis.",
        ),
        "target": attr.label(
            allow_files = True,
            doc = "Analysis target to be stored.",
        ),
    },
    outputs = {
        "test_script": "%{name}/store_script.sh",
    },
    # Can only depend on a test action (codechecker_test/per_file_test)
    # if this itself is a test action too.
    test = True,
)
