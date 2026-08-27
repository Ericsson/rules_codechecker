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
Rule for storing CodeChecker analysis results on a remote server.

Usage:
    bazel run :my_store -- --url=http://localhost:8001/Default --name=my_run
"""

def _store_impl(ctx):
    # Resolve CodeChecker from the toolchain
    if ctx.attr.toolchain:
        info = ctx.attr.toolchain[platform_common.ToolchainInfo].codecheckerinfo
    else:
        info = ctx.toolchains["//:toolchain_type"].codecheckerinfo

    # Collect codechecker_files entries from targets.
    #
    # Each entry is passed to the store script via --files. Entries may
    # be either:
    #   * a directory (monolithic codechecker_test): report data lives
    #     in a "data" subdirectory inside it, and
    #   * individual report files (per_file_test): plists/logs that
    #     already live directly under the target's "data" directory.
    # The store script inspects each --files entry at runtime and
    # handles directories and individual files accordingly.
    codechecker_files_entries = []
    all_source_files = []
    for target in ctx.attr.targets:
        if OutputGroupInfo in target:
            plist_files = target[OutputGroupInfo].codechecker_files.to_list()
            codechecker_files_entries.extend(plist_files)
            source_files = target[OutputGroupInfo].source_files.to_list()
            all_source_files.extend(source_files)

    if not codechecker_files_entries:
        fail("No codechecker_files found in targets. " +
             "Make sure targets are codechecker_test or " +
             "per_file_test rules.")

    store_script = ctx.attr._store_script[DefaultInfo].files_to_run

    # Build --files arguments for each codechecker_files entry
    files_args = " ".join([
        "--files='{}'".format(d.short_path)
        for d in codechecker_files_entries
    ])

    # Generate the launcher shell script
    launcher = ctx.actions.declare_file(
        ctx.label.name + "_launcher.sh",
    )
    strip_regex_arg = " ".join([
        "--strip_regex '{}'".format(pattern)
        for pattern in ctx.attr.strip_regex
    ])
    ctx.actions.write(
        output = launcher,
        content = """#!/bin/bash
exec {script} \
    --codechecker_path '{codechecker}' \
    {strip_regex_arg} \
    {files_args} \
    "$@"
""".format(
            script = store_script.executable.short_path,
            codechecker = info.codechecker.short_path,
            strip_regex_arg = strip_regex_arg,
            files_args = files_args,
        ),
        is_executable = True,
    )

    run_files = (
        codechecker_files_entries +
        all_source_files +
        [launcher] +
        info.runfiles.to_list()
    )
    all_runfiles = ctx.runfiles(files = run_files)
    all_runfiles = all_runfiles.merge(
        ctx.attr._store_script[DefaultInfo].default_runfiles,
    )

    return [
        DefaultInfo(
            executable = launcher,
            runfiles = all_runfiles,
        ),
    ]

_store = rule(
    implementation = _store_impl,
    attrs = {
        "strip_regex": attr.string_list(
            default = [],
            doc = "List of regexes matching the sandbox prefix. " +
                  "Patterns are applied in order. Each match " +
                  "is replaced with the directory where the store " +
                  "script runs, re-anchoring paths produced on " +
                  "a remote executor. Defaults to everything up to " +
                  "and including the  'execroot/<workspace>/' marker.",
        ),
        "targets": attr.label_list(
            doc = "List of codechecker_test targets " +
                  "whose results should be stored.",
        ),
        "toolchain": attr.label(
            default = None,
            doc = "Optional toolchain() target. " +
                  "When set, tools from this target are used " +
                  "instead of Bazel's toolchain resolution.",
        ),
        "_store_script": attr.label(
            allow_files = True,
            executable = True,
            cfg = "target",
            default = ":store_script",
        ),
    },
    executable = True,
    toolchains = ["//:toolchain_type"],
)

def store(
        name,
        targets,
        toolchain = None,
        strip_regex = [],
        tags = [],
        **kwargs):
    """
    Macro to create a CodeChecker store target.

    Run with:
        bazel run :<name> -- --url=<server_url> --name=<run_name>

    Args:
        name: Name of the store target.
        targets: List of codechecker_test targets whose
                 results should be stored.
        toolchain: Optional toolchain() target.
        strip_regex: List of regexes matching the sandbox prefix.
                  Patterns are applied in order. Each match
                  is replaced with the directory where the store
                  script runs, re-anchoring paths produced on
                  a remote executor. Defaults to everything up to
                  and including the  'execroot/<workspace>/' marker.
        tags: Bazel tags.
        **kwargs: Other miscellaneous arguments.
    """
    store_tags = [] + tags
    if "store" not in tags:
        store_tags.append("store")
    _store(
        name = name,
        targets = targets,
        toolchain = toolchain,
        strip_regex = strip_regex,
        tags = store_tags,
        # Needed to be able to depend on test targets.
        testonly = True,
        **kwargs
    )
