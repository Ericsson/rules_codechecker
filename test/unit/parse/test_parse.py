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
Test wether CodeChecker parse and CodeChecker store
runs correctly on the produced report files
"""
import os
from tempfile import TemporaryDirectory
import unittest
from typing import final
from common.base import TestBase
from common.codechecker_server import CodeCheckerServer


class TestTemplate(TestBase):
    """Test CodeChecker parse, store"""

    # Set working directory
    __test_path__ = os.path.dirname(os.path.abspath(__file__))
    BAZEL_BIN_DIR = os.path.join(
        "../../..", "bazel-bin", "test", "unit", "parse"
    )
    BAZEL_TESTLOGS_DIR = os.path.join(
        "../../..", "bazel-testlogs", "test", "unit", "parse"
    )

    @final
    @classmethod
    def setUpClass(cls):
        """Start CodeChecker server"""
        super().setUpClass()
        cls.codechecker_server = CodeCheckerServer()

    @final
    @classmethod
    def tearDownClass(cls):
        """Stop CodeChecker server"""
        del cls.codechecker_server
        super().tearDownClass()

    def check_store(self, path: str, name: str):
        """
        Tries to store the results on the codechecker server,
        asserts for successful storing.

        Args:
            path - Path of the result files
            name - name of the project to be saved under
        """
        port = getattr(self.codechecker_server, 'port', 8001)
        ret, stdout, stderr = self.run_command(
            f"CodeChecker store {path} -n {name}"
            f" --url=http://localhost:{port}/Default"
        )
        self.assertEqual(ret, 0, stdout + "\n" + stderr)

    def check_parse(self, path: str, will_find_bug: bool = True):
        """
        Checks if the parse command finishes correctly on results.

        Args:
            path - Path of the result files
            will_find_bug - Will there be a bug in the result files,
            changes on what we assert
        """
        ret, _, _ = self.run_command(f"CodeChecker parse {path}")
        self.assertEqual(ret, 2 if will_find_bug else 0)

    def test_parse_html(self):
        """Test: Parse results into html"""
        ret, _, stderr = self.run_command(
            "bazel build //test/unit/parse:codechecker"
        )
        self.assertEqual(ret, 0, stderr)
        self.check_parse(
            f"{self.BAZEL_BIN_DIR}/codechecker/codechecker-files/data"
        )

    def test_store(self):
        """Test: Storing to CodeChecker server"""
        # FIXME: CodeChecker store wants to create a temporary folder inside
        # the report folder. Bazel's output folder however is readonly.
        # Adding the flag: "--experimental_writable_outputs"
        # makes the directory writeable
        ret, _, stderr = self.run_command(
            "bazel build //test/unit/parse:codechecker "
            "--experimental_writable_outputs"
        )
        self.assertEqual(ret, 0, stderr)
        self.check_store(
            f"{self.BAZEL_BIN_DIR}/codechecker/codechecker-files/data",
            "unit_test_bazel",
        )

    def test_store_rule(self):
        """Test: Storing to CodeChecker server with custom rule"""
        port = getattr(self, 'port', 8001)
        with TemporaryDirectory(dir=".") as temp_dir:
            with open(f"{temp_dir}/BUILD", "w", encoding="utf-8") as build_file:
                build_file.write(f"""
load(
    "//src:codechecker_store.bzl",
    "codechecker_store_test"
)
                                 
codechecker_store_test(
    name = "store_codechecker",
    tags = ["manual"],
    target = "//test/unit/parse:codechecker",
    url = "http://localhost:{port}/Default",
)
                                 """)
            ret, _, stderr = self.run_command(
                f"bazel test //test/unit/parse/{os.path.basename(temp_dir)}"
                ":store_codechecker"
            )
            self.assertEqual(ret, 0, stderr)


if __name__ == "__main__":
    unittest.main(buffer=True)
