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
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.

"""
CodeChecker store wrapper script.

Uploads CodeChecker analysis results to a remote server.
Copies report data into a writable temporary directory first,
because Bazel output directories are read-only and CodeChecker store
needs to create temporary files inside the report directory. While
copying, absolute paths embedded in the plist report files are
re-anchored to where this script runs (the runfiles root), so results
produced on a remote executor resolve against the local checkout.
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile


# Default regex matching the prefix of bazel's sandbox, on local machines.
# Users may replace it with the prefix of their remote executors.
DEFAULT_STRIP_REGEX = r"/\S*?/execroot/[^/]+/"


def rewrite_plist_paths(data, anchor, strip_regexes=None):
    """
    Re-anchor prefixed absolute paths in plist content.

    Everything matched by any of `strip_regexes` is stripped
    from each path and replaced with `anchor`, so paths produced on a
    remote executor (with its own execroot prefix) resolve where the
    store script actually runs. Patterns are applied in order, so a
    later pattern sees the result of the earlier ones.

    Args:
        data: The textual plist content.
        anchor: Directory to anchor the stripped, workspace-relative
            tail under (normally the runfiles root / cwd). A single
            trailing slash is ensured.
        strip_regexes: Iterable of regexes matching the leading portion
            of each path to strip. Defaults to `[DEFAULT_STRIP_REGEX]`.
    Returns:
        The rewritten plist content.
    """
    if not strip_regexes:
        strip_regexes = [DEFAULT_STRIP_REGEX]
    anchor = anchor.rstrip("/") + "/"
    for strip_regex in strip_regexes:
        data = re.sub(strip_regex, anchor, data)
    return data


def parse_args(argv=None):
    """Parse command-line arguments.

    Returns a `(args, passthrough)` tuple where `args` holds the
    arguments consumed by this wrapper and `passthrough` is the list of
    arguments provided by the user as "real" command line arguments
    (forwarded to `CodeChecker store`).
    """
    parser = argparse.ArgumentParser(
        description="CodeChecker store wrapper"
    )
    parser.add_argument(
        "--codechecker_path",
        required=True,
        help="Path to the CodeChecker executable",
    )
    parser.add_argument(
        "--strip_regex",
        action="append",
        default=None,
        help=(
            "Regex matching the Bazel sandbox prefix of each absolute path "
            "in the plist report files to strip. May be repeated to "
            "supply multiple patterns, which are applied in order. "
            "Defaults to everything up to and including the "
            "'execroot/<workspace>/' marker. Override this to match "
            "your remote executor's path layout."
        ),
    )
    parser.add_argument(
        "--files",
        required=True,
        action="append",
        help=(
            "Path to a codechecker-files entry (may be repeated for "
            "multiple targets). Each entry is either a directory "
            "containing a 'data' subdirectory (monolithic "
            "codechecker_test) or an individual report file such as a "
            ".plist (per_file_test)."
        ),
    )
    args, passthrough = parser.parse_known_args(argv)
    return args, passthrough


def _copy_leaf(src, dst, anchor, strip_regexes):
    """
    Copy a single report file from `src` to `dst`.

    `.plist` files are rewritten so their embedded absolute paths are
    re-anchored under `anchor` (see `rewrite_plist_paths`); all other
    files are copied verbatim.
    """
    if os.path.lexists(dst):
        os.remove(dst)
    if src.endswith(".plist"):
        with open(src, "r", encoding="utf-8") as plist_file:
            data = plist_file.read()
        with open(dst, "w", encoding="utf-8") as out_file:
            out_file.write(rewrite_plist_paths(data, anchor, strip_regexes))
    else:
        shutil.copy2(os.path.realpath(src), dst)


def _copy_tree(src_dir, dst_dir, anchor, strip_regexes):
    """
    Recursively copy the directory tree of `src_dir` into `dst_dir`,
    creating writable directories and copying leaf files via
    `_copy_leaf` (which rewrites plist files).
    """
    os.makedirs(dst_dir, exist_ok=True)
    for entry in os.listdir(src_dir):
        src = os.path.join(src_dir, entry)
        dst = os.path.join(dst_dir, entry)
        if os.path.isdir(src):
            _copy_tree(src, dst, anchor, strip_regexes)
        else:
            _copy_leaf(src, dst, anchor, strip_regexes)


def copy_data_to_tmpdir(codechecker_files_entries, anchor, strip_regexes):
    """
    Build a single writable temporary directory holding a copy of the
    report data from each codechecker-files entry.

    Plist files are rewritten so their prefixed paths resolve against
    `anchor` (see `_copy_leaf`); all other files are copied verbatim.

    Each entry is one of:
      * A directory (monolithic codechecker_test): its "data"
        subdirectory holds the report files, which are copied in.
      * An individual report file (per_file_test): plists, logs and
        metadata that already live directly under a "data" directory.
        These are copied in directly.

    Args:
        codechecker_files_entries: list of --files entries.
        anchor: Directory to re-anchor stripped plist paths under.
        strip_regexes: Iterable of regexes matching the leading portion
            of each plist path to strip.
    Returns the path to the temporary directory containing
    the merged report files.
    """
    tmpdir = tempfile.mkdtemp(prefix="cc_store_")
    for entry in codechecker_files_entries:
        if os.path.isdir(entry):
            # Monolithic target: reports live in "<entry>/data".
            data_dir = os.path.join(entry, "data")
            if not os.path.isdir(data_dir):
                print(
                    f"WARNING: {data_dir} does not exist, "
                    "skipping.",
                    file=sys.stderr,
                )
                continue
            _copy_tree(data_dir, tmpdir, anchor, strip_regexes)
        elif os.path.isfile(entry):
            # per_file target: an individual report file. Only .plist
            # report files belong in the store directory.
            if not entry.endswith(".plist"):
                continue
            dst = os.path.join(tmpdir, os.path.basename(entry))
            _copy_leaf(entry, dst, anchor, strip_regexes)
        else:
            print(
                f"WARNING: {entry} does not exist, skipping.",
                file=sys.stderr,
            )
    return tmpdir


def print_tree(root, prefix="", skip_dirs=None):
    """
    Print an indented tree of `root`, similar to the Unix `tree`
    command. Debug feature. TODO: Remove

    `skip_dirs` is an optional collection of directory names to skip.
    Matching directories are still listed but shown with a
    "[skipped]" marker and are not recursed into, which keeps noisy
    subtrees (e.g. bundled interpreter/runtime folders) out of the
    output while still showing they exist.
    """
    skip_dirs = set(skip_dirs or ())
    if not prefix:
        print(root)
    try:
        entries = sorted(
            os.listdir(root),
            key=lambda name: (
                not os.path.isdir(os.path.join(root, name)),
                name,
            ),
        )
    except OSError as err:
        print(f"{prefix}[error reading directory: {err}]")
        return

    for index, entry in enumerate(entries):
        path = os.path.join(root, entry)
        is_last = index == len(entries) - 1
        connector = "└── " if is_last else "├── "
        is_dir = os.path.isdir(path) and not os.path.islink(path)

        if os.path.islink(path):
            target = os.path.realpath(path)
            print(f"{prefix}{connector}{entry} -> {target}")
        elif is_dir and entry in skip_dirs:
            print(f"{prefix}{connector}{entry} [skipped]")
            continue
        else:
            print(f"{prefix}{connector}{entry}")

        if is_dir:
            extension = "    " if is_last else "│   "
            print_tree(path, prefix + extension, skip_dirs)


def run_store(codechecker_path, tmpdir, store_args):
    """
    Execute CodeChecker store on the temporary directory.

    `store_args` is the list of extra arguments given by the user to
    `CodeChecker store` (e.g. --url, --name/-n, --trim-path-prefix).
    Returns the process exit code.
    """
    cmd = [
        codechecker_path,
        "store",
        tmpdir,
        *store_args,
    ]
    print(f"Running: {' '.join(cmd)}")
    result = subprocess.run(
        cmd,
        capture_output=False,
        check=False,
    )
    return result.returncode


def main():
    """Main entry point."""
    args, passthrough = parse_args()

    codechecker = os.path.realpath(args.codechecker_path)
    if not os.path.isfile(codechecker):
        print(
            f"ERROR: CodeChecker not found: {codechecker}",
            file=sys.stderr,
        )
        sys.exit(1)

    # Re-anchor execroot-prefixed plist paths under the current working
    # directory, which at `bazel run` time is the runfiles root where
    # the report sources are laid out.
    anchor = os.getcwd()

    # Copy report data to a writable location, rewriting plist paths.
    tmpdir = copy_data_to_tmpdir(args.files, anchor, args.strip_regex)

    # Show the layout so the copied/rewritten report data is easy to
    # inspect.
    print(f"Sandbox tree: {os.getcwd()}")
    print_tree(".", skip_dirs=["external"])

    try:
        ret = run_store(codechecker, tmpdir, passthrough)
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)

    sys.exit(ret)


if __name__ == "__main__":
    main()
