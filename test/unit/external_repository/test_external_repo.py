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
Test external repositories with codechecker
"""
import logging
import os
import shutil
import unittest
from typing import final
from common.base import TestBase


class TestImplDepExternalDep(TestBase):
    """Test external repositories with codechecker"""

    # Set working directory
    __test_path__ = os.path.dirname(os.path.abspath(__file__))
    BAZEL_BIN_DIR = os.path.join("bazel-bin")
    BAZEL_TESTLOGS_DIR = os.path.join("bazel-testlogs")
    BAZEL_VERSION = None

    @final
    @classmethod
    def setUpClass(cls):
        """
        Copy bazelversion from main, otherwise bazelisk will download the latest
        bazel version.
        """
        # The folder bazel-external_repository
        # created by bazel during bazel build/test
        # contains a copy of this test file
        # and the unittest test discovery finds it.
        # This is why, it is imperative that these directories get cleared
        cls.run_command("bazel clean")
        super().setUpClass()
        try:
            shutil.copy("../../../.bazelversion", ".bazelversion")
            shutil.copy(
                "../../../.bazelversion", "third_party/my_lib/.bazelversion"
            )
        # If no such file exists assume user doesn't use bazelisk
        # This file is not needed
        except FileNotFoundError:
            logging.debug("No bazel version set, using system default")
        _, stdout, _ = cls.run_command("bazel --version")
        cls.BAZEL_VERSION = stdout.split(" ")[2].strip()
        logging.debug("Bazel version: %s", cls.BAZEL_VERSION)
        major_version = int(cls.BAZEL_VERSION.split(".")[0])
        if major_version < 7:
            raise unittest.SkipTest("Skip tests for Bazel older than 7")

    @final
    @classmethod
    def tearDownClass(cls):
        """Remove bazelversion from this test"""
        super().tearDownClass()
        # The folder bazel-external_repository contains this script
        # and the unittest test discovery finds it.
        # This is why, it is imperative that these directories get cleared
        cls.run_command("bazel clean")
        try:
            os.remove(".bazelversion")
        # If no such file exists assume user doesn't use bazelisk
        # This file was not needed
        except FileNotFoundError:
            pass
        try:
            os.remove("third_party/my_lib/.bazelversion")
        # If no such file exists assume user doesn't use bazelisk
        # This file was not needed
        except FileNotFoundError:
            pass

    def test_compile_commands_external_lib(self):
        """
        Test: bazel build :compile_commands_isystem "
        "--experimental_cc_implementation_deps
        """
        ret, _, stderr = self.run_command(
            "bazel build :compile_commands_isystem "
            "--experimental_cc_implementation_deps"
        )
        self.assertEqual(ret, 0, stderr)
        comp_json_file = os.path.join(
            self.BAZEL_BIN_DIR,  # pyright: ignore
            "compile_commands_isystem",
            "compile_commands.json",
        )

        pattern1 = r"-isystem external/external_lib./include"
        pattern2 = (
            r"-isystem bazel-out/k8-fastbuild/bin/external/"
            "external_lib./include"
        )

        self.assertTrue(self.contains_regex_in_file(comp_json_file, pattern1))
        self.assertTrue(self.contains_regex_in_file(comp_json_file, pattern2))

    def test_codechecker_external_lib(self):
        """
        Test: bazel build :codechecker_external_deps
        --experimental_cc_implementation_deps
        """
        ret, _, stderr = self.run_command(
            "bazel build :codechecker_external_deps "
            "--experimental_cc_implementation_deps"
        )
        self.assertEqual(ret, 0, stderr)

    def test_per_file_external_lib(self):
        """Test: bazel build :per_file_external_deps "
        "--experimental_cc_implementation_deps"""
        ret, _, stderr = self.run_command(
            "bazel build :per_file_external_deps "
            "--experimental_cc_implementation_deps"
        )
        self.assertEqual(ret, 0, stderr)


if __name__ == "__main__":
    unittest.main(buffer=True)
