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
Test the skip option for codechecker rules.
"""
import os
import unittest
from common.base import TestBase


class TestSkip(TestBase):
    """Tests involving the skip argument of codechecker rules"""

    # Set working directory
    __test_path__ = os.path.dirname(os.path.abspath(__file__))
    BAZEL_BIN_DIR = os.path.join(
        "../../..", "bazel-bin", "test", "unit", "skip"
    )
    BAZEL_TESTLOGS_DIR = os.path.join(
        "../../..", "bazel-testlogs", "test", "unit", "skip"
    )

    def test_codechecker_skipfile(self):
        """
        Test: bazel test //test/unit/skip:codechecker_skipfile
        """
        ret, _, stderr = self.run_command(
            "bazel test //test/unit/skip:codechecker_skipfile"
        )
        self.assertEqual(ret, 0, stderr)

    def test_per_file_skipfile_full_path(self):
        """
        Test: bazel test //test/unit/skip:per_file_skipfile_full_path
        """
        ret, _, stderr = self.run_command(
            "bazel test //test/unit/skip:per_file_skipfile_full_path"
        )
        self.assertEqual(ret, 3, stderr)
        log_file = (
            f"{self.BAZEL_TESTLOGS_DIR}/per_file_skipfile_full_path/test.log"
        )
        # FIXME: change to assertFalse, this file should be skipped
        self.assertTrue(
            self.contains_regex_in_file(log_file, r"defect\(s\) in skip.cc")
        )
        self.assertTrue(
            self.contains_regex_in_file(log_file, r"defect\(s\) in skip2.cc")
        )

    def test_per_file_skipfile_folder_skip_path(self):
        """
        Test: bazel test //test/unit/skip:per_file_skipfile_folder_skip_path
        """
        ret, _, stderr = self.run_command(
            "bazel test //test/unit/skip:per_file_skipfile_folder_skip_path"
        )
        self.assertEqual(ret, 3, stderr)
        log_file = (
            f"{self.BAZEL_TESTLOGS_DIR}/"
            "per_file_skipfile_folder_skip_path/test.log"
        )
        # FIXME: change to assertFalse, this file should be skipped
        self.assertTrue(
            self.contains_regex_in_file(log_file, r"defect\(s\) in skip.cc")
        )
        self.assertTrue(
            self.contains_regex_in_file(log_file, r"defect\(s\) in skip2.cc")
        )

    def test_per_file_skipfile_both_files(self):
        """
        Test: bazel test //test/unit/skip:per_file_skipfile_both_files
        """
        ret, _, stderr = self.run_command(
            "bazel test //test/unit/skip:per_file_skipfile_both_files"
        )
        # FIXME: The return code here should be 0, both files should be skipped
        self.assertEqual(ret, 3, stderr)
        log_file = (
            f"{self.BAZEL_TESTLOGS_DIR}/per_file_skipfile_both_files/test.log"
        )
        self.assertTrue(
            self.contains_regex_in_file(log_file, r"defect\(s\) in skip.cc")
        )
        self.assertTrue(
            self.contains_regex_in_file(log_file, r"defect\(s\) in skip2.cc")
        )


if __name__ == "__main__":
    unittest.main(buffer=True)
