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
FOSS integration test runner for rules_codechecker.

Creates a Bazel project that depends on a FOSS module from the Bazel Central
Registry, builds codechecker targets on it, and verifies the outputs.
"""

import argparse
import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

MODULE_TEMPLATE = """
bazel_dep(name = "{module}", version = "{version}")

bazel_dep(name = "rules_codechecker")
local_path_override(
    module_name = "rules_codechecker",
    path = "{rules_path}",
)
"""

BUILD_TEMPLATE = """
load("@rules_codechecker//:defs.bzl", "codechecker_test", "compile_commands")

codechecker_test(
    name = "codechecker_test",
    targets = ["{target}"],
)

codechecker_test(
    name = "codechecker_per_file",
    per_file = True,
    targets = ["{target}"],
)

compile_commands(
    name = "compile_commands",
    targets = ["{target}"],
)
"""


class FossTest(unittest.TestCase):
    """Runs rules_codechecker on a FOSS project from the registry."""

    # Set by main()
    module = None
    version = None
    target = None
    tests = []

    def setUp(self):
        self.work_dir = Path(tempfile.mkdtemp())
        self.output_base = self.work_dir / ".bazel_output"
        self.rules_path = Path(__file__).resolve().parents[2]
        self._setup_bazel_project()

    def tearDown(self):
        self._bazel("shutdown")
        shutil.rmtree(self.work_dir, ignore_errors=True)

    def _setup_bazel_project(self):
        """Write the project depending on the FOSS module and on our rules"""
        (self.work_dir / "MODULE.bazel").write_text(
            MODULE_TEMPLATE.format(
                module=self.module,
                version=self.version,
                rules_path=self.rules_path,
            )
        )
        (self.work_dir / "BUILD.bazel").write_text(
            BUILD_TEMPLATE.format(target=self.target)
        )

    def _bazel(self, *arguments):
        """Run bazel in the generated project, return the completed process"""
        return subprocess.run(
            ["bazel", f"--output_base={self.output_base}"] + list(arguments),
            cwd=self.work_dir,
            capture_output=True,
            check=False,
            text=True,
        )

    def _bazel_build(self):
        targets = [f"//{test}" for test in self.tests]
        result = self._bazel("build", *targets)
        self.assertEqual(result.returncode, 0,
                         f"bazel build failed:\n{result.stderr}")

    def _bazel_bin(self):
        return Path(self._bazel("info", "bazel-bin").stdout.strip())

    def test_build_succeeds(self):
        """Verify that codechecker rules build successfully."""
        self._bazel_build()

    def test_compile_commands_valid(self):
        """Verify compile_commands.json is valid and non-empty."""
        self._bazel_build()
        commands = (self._bazel_bin() / "compile_commands"
                    / "compile_commands.json")
        self.assertTrue(commands.exists(),
                        f"compile_commands.json not found at {commands}")
        entries = json.loads(commands.read_text())
        self.assertIsInstance(entries, list)
        self.assertGreater(len(entries), 0, "compile_commands.json is empty")
        for entry in entries:
            self.assertIn("file", entry)
            self.assertIn("directory", entry)

    def test_codechecker_outputs_exist(self):
        """Verify codechecker produces expected output files."""
        self._bazel_build()
        analysis_dir = self._bazel_bin() / "codechecker_test"
        self.assertTrue(analysis_dir.exists(),
                        f"codechecker output dir not found at {analysis_dir}")
        self.assertTrue((analysis_dir / "compile_commands.json").exists(),
                        "codechecker compile_commands.json not found")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--module", required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--target", required=True)
    parser.add_argument("--tests", nargs="+", required=True)
    arguments, remaining = parser.parse_known_args()

    FossTest.module = arguments.module
    FossTest.version = arguments.version
    FossTest.target = arguments.target
    FossTest.tests = arguments.tests

    unittest.main(argv=[sys.argv[0]] + remaining)
