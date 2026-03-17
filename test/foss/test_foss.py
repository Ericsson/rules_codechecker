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
Test the rule integrated into open source projects
"""

import logging
import shutil
import subprocess
import unittest
import os
import tempfile
from pathlib import Path
from types import FunctionType
import yaml
from common.base import TestBase

ROOT_DIR = f"{os.path.dirname(os.path.abspath(__file__))}/"


def get_test_config() -> list[Path]:
    """
    Collect config files for test projects
    """
    path = Path(ROOT_DIR)
    yaml_files = list(path.rglob("*.yaml")) + list(path.rglob("*.yml"))
    return yaml_files


def get_bazel_version():
    """
    Return the installed Bazel version string
    """
    out = subprocess.check_output(["bazel", "--version"], text=True).strip()
    version = out.split(" ")[1]
    return version


BAZEL_VERSION = get_bazel_version()
BAZEL_MAJOR_VERSION = BAZEL_VERSION.split(".")[0]


# This will contain the generated tests.
class FOSSTestCollector(TestBase):
    """
    Test class for FOSS tests
    """

    # Set working directory
    __test_path__ = os.path.dirname(os.path.abspath(__file__))
    # These are irrelevant for these kind of tests
    BAZEL_BIN_DIR = os.path.join("")
    BAZEL_TESTLOGS_DIR = os.path.join("")


# Creates test functions with the parameter: directory_name. Based on:
# https://eli.thegreenplace.net/2014/04/02/dynamically-generating-python-test-cases
def create_test_method(
    project_name: str,
    url: str,
    targets: list[dict[str, str]],
    context,
    bzlmod,
) -> FunctionType:
    """
    Returns a function pointer that points to a function for the given directory
    """
    git_hash = context["hash"]
    patch = context.get("patch", "")

    def test_runner(self) -> None:
        with tempfile.TemporaryDirectory() as test_dir:
            self.assertTrue(os.path.exists(test_dir))
            logging.info("Initializing project...")
            subprocess.run(["git", "clone", url, test_dir], check=True)
            subprocess.run(
                [
                    "git",
                    "-C",
                    test_dir,
                    "checkout",
                    git_hash,  # pyright: ignore
                ],
                check=True,
            )

            bazelversion = Path("../../.bazelversion")
            if bazelversion.is_file():
                shutil.copy(
                    bazelversion, os.path.join(test_dir, ".bazelversion")
                )

            build_file = Path(os.path.join(test_dir), "BUILD")
            if not build_file.is_file():
                build_file = Path(os.path.join(test_dir), "BUILD.bazel")
            if not build_file.is_file():
                self.fail(
                    f"No build file found for project {project_name}",
                )

            with open(build_file, "a", encoding="utf-8") as f:
                f.write(
                    "#-------------------------------------------------------\n"
                    "# codechecker rules\n"
                    "load(\n"
                    '"@rules_codechecker//src:codechecker.bzl",\n'
                    '"codechecker_test",\n'
                    ")\n"
                )
                for target in targets:
                    target_name = target["name"]
                    f.write(
                        "codechecker_test(\n"
                        f'name = "codechecker_test_{target_name}",\n'
                        "targets = [\n"
                        f'":{target_name}",\n'
                        "],\n"
                        ")\n"
                    )
                    f.write(
                        "codechecker_test(\n"
                        f'name = "per_file_test_{target_name}",\n'
                        "targets = [\n"
                        f'":{target_name}",\n'
                        "],\n"
                        "per_file = True,\n"
                        ")\n"
                    )
                f.write(
                    "#-------------------------------------------------------\n"
                )
            if bzlmod:
                module_template = Path("templates/MODULE.template").read_text(
                    "utf-8"
                )
                module_final = module_template.replace(
                    "{rule_path}",
                    f"{os.path.dirname(os.path.abspath(__file__))}/../../",
                )
                module_file = Path(os.path.join(test_dir, "MODULE.bazel"))
                with open(module_file, "a", encoding="utf-8") as f:
                    f.write(module_final)
                if BAZEL_MAJOR_VERSION == "6":
                    with open(
                        os.path.join(test_dir, ".bazelrc"),
                        "a",
                        encoding="utf-8",
                    ) as f:
                        f.write("common --enable_bzlmod")
                    Path(os.path.join(test_dir, "WORKSPACE")).touch()
            else:
                workspace_template = Path(
                    "templates/WORKSPACE.template"
                ).read_text("utf-8")
                workspace_final = workspace_template.replace(
                    "{rule_path}",
                    f"{os.path.dirname(os.path.abspath(__file__))}/../../",
                )
                workspace_file = Path(os.path.join(test_dir, "WORKSPACE"))
                with open(workspace_file, "a", encoding="utf-8") as f:
                    f.write(workspace_final)
            if patch:
                subprocess.run(patch, cwd=test_dir, check=True)
            logging.info("Running monolithic rule...")
            for target in targets:
                ret, _, stderr = self.run_command(
                    f"bazel build :codechecker_test_{target['name']}",
                    test_dir,
                )
                self.assertEqual(ret, 0, stderr)
            logging.info("Running per_file rule...")
            for target in targets:
                ret, _, stderr = self.run_command(
                    f"bazel build :per_file_test_{target['name']}", test_dir
                )
                self.assertEqual(ret, 0, stderr)

    return test_runner


# Dynamically add a test method for each project
# For each project config it adds new test functions to the class
# This must be outside of the __main__, to work well with pytest
for config_file in get_test_config():
    CONTENT = None
    with open(config_file, "r", encoding="utf-8") as conf:
        CONTENT = yaml.safe_load(conf)
    assert CONTENT is not None
    test_name: str = CONTENT["name"]

    for tag in CONTENT["version_tags"]:
        bazel_version: str = tag["bazel_version"]
        bzlmod_on: bool = tag.get("bzlmod", (int(bazel_version) >= 8))
        if bazel_version == BAZEL_MAJOR_VERSION:
            setattr(
                FOSSTestCollector,
                f"test_{test_name}_{'bzlmod' if bzlmod_on else 'workspace'}",
                create_test_method(
                    test_name,
                    CONTENT["url"],
                    CONTENT["targets"],
                    tag,
                    bzlmod_on,
                ),
            )

if __name__ == "__main__":
    unittest.main()
