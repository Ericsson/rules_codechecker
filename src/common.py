"""
Common utilities for running codechecker.
This module is shared between the "per_file_script.py"
and "codechecker_script.py" files.
"""

import logging
import shlex
import subprocess
import sys
import os
import re

def build_env(env, log, clang, clang_tidy):
    """Return environment"""
    new_env = os.environ.copy()
    for entry in env:
        if "=" not in entry:
            fail(log, f"Environment entry is not KEY=VALUE: {entry}")
        key, value = entry.split("=", 1)
        new_env[key] = value
    # Note: This is a workaround, CodeChecker requires the PATH to be set
    if "PATH" not in new_env:
        new_env["PATH"] = "/bin"
    if new_env.get("CC_ANALYZERS_FROM_PATH"):
        logging.debug("CC_ANALYZERS_FROM_PATH is set: use analyzers from PATH")
    elif new_env.get("CC_ANALYZER_BIN"):
        logging.debug("CC_ANALYZER_BIN is set by the configuration")
    else:
        new_env["CC_ANALYZER_BIN"] = (
            f"clangsa:{clang};clang-tidy:{clang_tidy}"
        )
    logging.debug("env: %s", str(new_env))
    return new_env


def execute(codechecker_log, cmd, env=None, codes=None):
    """Execute CodeChecker commands"""
    if codes is None:
        codes = [0]
    with subprocess.Popen(
        cmd,
        env=env,
        shell=True,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ) as process:
        stdout, stderr = process.communicate()
        stdout = stdout.decode("utf-8")
        stderr = stderr.decode("utf-8")
        if process.returncode not in codes:
            fail(
                codechecker_log,
                f"\ncommand: {cmd}\nstdout: {stdout}\nstderr: {stderr}\n",
            )
        logging.debug("Executing: %s", cmd)
        # logging.debug("Output:\n\n%s\n", stdout)
    return stdout


def read_file(codechecker_log, filename):
    """Read text file and return its contents"""
    if not os.path.isfile(filename):
        fail(codechecker_log, f"File not found: {filename}")
    with open(filename, encoding="utf-8") as handle:
        return handle.read()


def fail(codechecker_log, message, exit_code=1):
    """Print error message and return exit code"""
    logging.error(message)
    print()
    print("*" * 50)
    print("codechecker script execution FAILED!")
    if codechecker_log:
        print(f"See: {codechecker_log}")
        print("*" * 50)
        try:
            with open(codechecker_log, encoding="utf-8") as log_file:
                print(log_file.read())
        except IOError:
            print("File not accessible")
    else:
        print(message)
    print("*" * 50)
    print()
    sys.exit(exit_code)


def separator(method="info"):
    """Print log separator line to logging.info() or other logging methods"""
    getattr(logging, method)("#" * 23)


def stage(title, method="info"):
    """Print stage title into log"""
    separator(method)
    getattr(logging, method)("### " + title)
    separator(method)

# pylint: disable=too-many-arguments,too-many-positional-arguments
def parse(output_dir, codechecker, config, env, log, clang, clang_tidy):
    """Run CodeChecker parse commands"""
    stage("CodeChecker parse:")
    env = build_env(env, log, clang, clang_tidy)
    logging.info("CodeChecker parse -e json")
    codechecker_parse = (
        f"{codechecker} parse --config "
        f"{config} {output_dir}/data"
    )
    # Save results to JSON file
    command = (
        f"{codechecker_parse} --export=json > " f"{output_dir}/result.json"
    )
    execute(log, command, env=env, codes=[0, 2])
    # Save results as HTML report
    logging.info("CodeChecker parse -e html")
    command = (
        codechecker_parse + " --export=html --output=" + output_dir + "/report"
    )
    execute(log, command, env=env, codes=[0, 2])
    # Save results to text file
    logging.info("CodeChecker parse to text result")
    result_file = output_dir + "/result.txt"
    command = codechecker_parse + " > " + result_file
    execute(log, command, env=env, codes=[0, 2])
    logging.info("Result:\n\n%s\n", read_file(log, result_file))


def check_results(output_dir, log, severities):
    """Check/verify CodeChecker results"""
    stage("Checking result:")
    # Get results file and read it
    result_file = output_dir + "/result.txt"
    logging.info("Find CodeChecker results in bazel-bin")
    logging.info("      all artifacts: %s/", output_dir)
    logging.info("      HTML report:   %s/report/index.html", output_dir)
    logging.info("      result file:   %s", result_file)
    results = read_file(log, result_file)
    logging.info("Results: \n\n%s\n", results)
    # Collect defect severities to detect
    if severities is None:
        fail(
            log,
            "CodeChecker defect severities are invalid: "
            f"{str(severities)}",
        )
    severities = shlex.split(severities) # pyright: ignore[reportArgumentType]
    # Add HIGH severity by default
    if not severities:
        severities.append("HIGH")
    # We should always detect CRITICAL defects
    if "CRITICAL" not in severities:
        severities.append("CRITICAL")
    logging.debug("Severities: %s", str(severities))
    issues = dict.fromkeys(severities, 0)
    logging.debug("Issues: %s", str(issues))
    # Grep results for defects according to severities
    for issue in issues:
        found = re.findall(rf"^{issue} .* (\d+)", results, re.M)
        defects = sum(int(number) for number in found)
        logging.debug("   %s : %s = %d", issue, str(found), defects)
        issues[issue] = defects
    logging.info("Defects: %s", str(issues))
    # Check collected defects
    passed = True
    conclusion = ""
    for issue, num in issues.items():
        if num > 0:
            passed = False
            conclusion += f"{issue:>15} : {num}\n"
    if passed:
        logging.info("No defects found by CodeChecker")
    else:
        fail(log, f"CodeChecker found defects:\n{conclusion}")
