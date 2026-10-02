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
CodeChecker Bazel build & test wrapper script
"""

import argparse
import logging
import os
import plistlib
import re
from common import fail, parse, check_results, stage, execute, build_env

START_PATH = r"\/(?:(?!\.\s+)\S)+"
BAZEL_PATHS = {
    r"\/sandbox\/processwrapper-sandbox\/\S*\/execroot\/": "/execroot/",
    START_PATH + r"\/worker\/build\/[0-9a-fA-F]{16}\/root\/": "",
    START_PATH + r"\/[0-9a-fA-F]{32}\/execroot\/": "",
}


def parse_args(argv=None):
    """Parse command-line arguments"""
    parser = argparse.ArgumentParser(description="CodeChecker Bazel Wrapper")

    parser.add_argument("--mode", required=True, help="Execution mode")
    parser.add_argument("--verbosity", default="INFO", help="Log level")
    parser.add_argument("--codechecker", required=True,
                        help="CodeChecker path")
    parser.add_argument("--clang-tidy", help="clang-tidy path")
    parser.add_argument("--clang", help="clang path")
    parser.add_argument("--commands", dest="compile_commands",
                        help="compile_commands.json file")
    parser.add_argument("--skip", help="Skipfile path")
    parser.add_argument("--config", help="Config file path")
    parser.add_argument("--analyze", default="", help="Analysis options")
    parser.add_argument("--output",
                        help="Directory where CodeChecker saves results")
    parser.add_argument("--log", help="Log file path")
    parser.add_argument("--env", action="append", default=[],
                        help="Environment variable, as KEY=VALUE")
    parser.add_argument("--severities", help="List of severities to fail on")
    args = parser.parse_args(argv)

    # Tools are symlinks in the runfiles tree
    args.codechecker = os.path.realpath(args.codechecker)
    if args.clang:
        args.clang = os.path.realpath(args.clang)
    if args.clang_tidy:
        args.clang_tidy = os.path.realpath(args.clang_tidy)
    return args


def setup(verbosity, codechecker_log):
    """Setup logging parameters for execution session"""
    if verbosity == "INFO":
        log_level = logging.INFO
    elif verbosity == "WARN":
        log_level = logging.WARN
    else:
        log_level = logging.DEBUG
    log_format = "[codechecker] %(levelname)5s: %(message)s"

    if codechecker_log:
        logging.basicConfig(
            filename=codechecker_log, level=log_level, format=log_format
        )
    else:
        logging.basicConfig(level=log_level, format=log_format)


def input_data(args):
    """Print out input (external) parameters"""
    stage("CodeChecker input data:", "debug")
    logging.debug("mode             : %s", args.mode)
    logging.debug("verbosity        : %s", args.verbosity)
    logging.debug("codechecker      : %s", args.codechecker)
    logging.debug("clang            : %s", args.clang)
    logging.debug("clang_tidy       : %s", args.clang_tidy)
    logging.debug("compile_commands : %s", args.compile_commands)
    logging.debug("skip             : %s", args.skip)
    logging.debug("config           : %s", args.config)
    logging.debug("analyze          : %s", args.analyze)
    logging.debug("output           : %s", args.output)
    logging.debug("log              : %s", args.log)
    logging.debug("env              : %s", args.env)
    logging.debug("")


def prepare(codechecker_files):
    """Prepare CodeChecker execution environment"""
    stage("CodeChecker files:")
    logging.info("Creating folder: %s", codechecker_files)
    if not os.path.exists(codechecker_files):
        os.makedirs(codechecker_files)


def analyze(args):
    """Run CodeChecker analyze command"""
    stage("CodeChecker analyze:")
    env = build_env(args.env, args.log, args.clang, args.clang_tidy)
    output = execute(
        args.log,
        f"{args.codechecker} analyzers --details",
        env=env,
    )
    logging.debug("Analyzers:\n\n%s", output)

    command = (
        f"{args.codechecker} analyze "
        f"--skip={args.skip} "
        f"{args.compile_commands} "
        f"--output={args.output}/data "
        f"--config {args.config} "
        f"{args.analyze}"
    )
    # FIXME: Workaround "CodeChecker simply remove compiler-rt include path".
    # This can be removed once codechecker 6.16.0 is used.
    # command += " --keep-gcc-intrin"
    logging.info("Running CodeChecker analyze...")
    output = execute(args.log, command, env=env)
    logging.info("Output:\n\n%s\n", output)
    if output.find("- Failed to analyze") != -1:
        logging.error("CodeChecker failed to analyze some files")
        fail(args.log, "Make sure that the target can be built first")


def fix_path_with_regex(data):
    """
    The absolute paths of the analyzed source files found in the plist files
    do not point to their original location, but rather wherever bazel copied
    them. This might either be in a subdirectory in bazel-bin on the
    local machine, or somewhere unrelated if the analysis was executed on a
    remote worker. This function tries to replace these paths to the location
    of the original location of the source file.
    """
    for pattern, replace in BAZEL_PATHS.items():
        data = re.sub(pattern, replace, data)
    return data


def fix_bazel_paths(codechecker_files):
    """Remove Bazel leading paths in all files"""
    stage("Fix CodeChecker output:")
    folder = codechecker_files
    logging.info("Fixing Bazel paths in %s", folder)
    counter = 0
    for root, _, files in os.walk(folder):
        for filename in files:
            fullpath = os.path.join(root, filename)
            with open(fullpath, "rt", encoding="utf-8") as data_file:
                data = fix_path_with_regex(data_file.read())
            with open(fullpath, "w", encoding="utf-8") as data_file:
                data_file.write(data)
            counter += 1
    logging.info("Fixed Bazel paths in %d files", counter)


def realpath(filename):
    """Return real full absolute path for given filename"""
    if os.path.exists(filename):
        real_file_name = os.path.abspath(os.path.realpath(filename))
        logging.debug("Updating %s -> %s", filename, real_file_name)
        filename = real_file_name
    return filename


def resolve_plist_symlinks(filepath):
    """Resolve the symbolic links in plist files to real file paths"""
    logging.info("Processing plist file: %s", filepath)
    with open(filepath, "rb") as input_file:
        file_contents = plistlib.load(input_file)
    if file_contents["files"]:
        final_files = []
        for entry in file_contents["files"]:
            final_files.append(realpath(entry))
        file_contents["files"] = final_files
        with open(filepath, "wb") as output_file:
            plistlib.dump(file_contents, output_file)


def resolve_yaml_symlinks(filepath):
    """Resolve the symbolic links in YAML files to real file paths"""
    logging.info("Processing YAML file: %s", filepath)
    fields = [
        r"MainSourceFile:\s*",
        r"\s*-? FilePath:\s*",
    ]
    updated = 0
    line_to_write = []
    with open(filepath, "r", encoding="utf-8") as input_file:
        for line in input_file.readlines():
            for field in fields:
                pattern = f"({field})'(.*)'"
                match = re.match(pattern, line)
                if match:
                    field = match.group(1)
                    filename = match.group(2)
                    fullpath = realpath(filename)
                    if fullpath != filename:
                        updated += 1
                        replace = f"{field}'{fullpath}'\r\n"
                        line = replace
                    break
            line_to_write.append(line)
    if updated:
        logging.debug("     %d updated paths", updated)
        with open(filepath, "w", encoding="utf-8") as output_file:
            logging.debug("     saving...")
            output_file.writelines(line_to_write)


def resolve_symlinks(codechecker_files):
    """Change ".../execroot/apps" paths to absolute paths in data/* files"""
    stage("Resolve file paths in CodeChecker analyze output:")
    analyze_outdir = codechecker_files + "/data"
    logging.info("Resolving file paths in CodeChecker analyze output at: %s",
                 analyze_outdir)
    files_processed = 0
    for root, _, files in os.walk(analyze_outdir):
        for filename in files:
            if re.search("clang-tidy", filename):
                filepath = os.path.join(root, filename)
                if os.path.splitext(filepath)[1] == ".plist":
                    resolve_plist_symlinks(filepath)
                elif os.path.splitext(filepath)[1] == ".yaml":
                    resolve_yaml_symlinks(filepath)
                files_processed += 1
    logging.info("Processed file paths in %d files", files_processed)


def update_file_paths(codechecker_files):
    """
    Fix bazel sandbox paths and resolve symbolic links
    in generated files to real paths
    """
    fix_bazel_paths(codechecker_files)
    resolve_symlinks(codechecker_files)


def run(args):
    """Perform all steps for "bazel build" phase"""
    prepare(args.output)
    analyze(args)
    parse(
        args.output,
        args.codechecker,
        args.config,
        args.env,
        args.log,
        args.clang,
        args.clang_tidy,
    )
    update_file_paths(args.output)


def test(args):
    """Perform all steps for "bazel test" phase"""
    check_results(args.output, args.log, args.severities)


def main():
    """Main function"""
    args = parse_args()
    setup(args.verbosity, args.log)
    input_data(args)
    try:
        if args.mode == "Run":
            run(args)
        elif args.mode == "Test":
            test(args)
        else:
            fail(args.log, f"Wrong codechecker script mode: {args.mode}")
    # We want to fail explicitly here
    # pylint: disable=broad-exception-caught
    except Exception as error:
        logging.exception(error)
        fail(args.log, "Caught Exception. Terminated")


if __name__ == "__main__":
    main()
