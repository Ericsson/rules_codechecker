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
Checks the metadata output of codechecker rules.
"""

import os
import unittest
from common.base import TestBase


class TestMetadata(TestBase):
    """Checks metadata result of jobs"""

    # Set working directory
    __test_path__ = os.path.dirname(os.path.abspath(__file__))
    BAZEL_BIN_DIR = os.path.join(
        "../../..", "bazel-bin", "test", "unit", "metadata"
    )
    BAZEL_TESTLOGS_DIR = os.path.join(
        "../../..", "bazel-testlogs", "test", "unit", "metadata"
    )

    def test_codechecker_metadata(self):
        """Test: bazel test //test/unit/metadata:codechecker_multiple_source"""
        ret, stdout, stderr = self.run_command(
            "bazel test //test/unit/metadata:codechecker_multiple_source"
        )
        self.assertEqual(3, ret, stdout + stderr)
        metadata_file = os.path.join(
            self.BAZEL_BIN_DIR,  # pyright: ignore
            "codechecker_multiple_source",
            "codechecker-files",
            "data",
            "metadata.json",
        )
        self.assertTrue(os.path.exists(metadata_file))
        self.assertNotEqual(
            self.grep_file(
                metadata_file,
                r"\"action_num\": 2,",
            ),
            [],
        )

    def test_per_file_metadata(self):
        """Test: bazel test //test/unit/metadata:per_file_multiple_source"""
        ret, stdout, stderr = self.run_command(
            "bazel test //test/unit/metadata:per_file_multiple_source"
        )
        self.assertEqual(3, ret, stdout + stderr)
        metadata_file = os.path.join(
            self.BAZEL_BIN_DIR,  # pyright: ignore
            "per_file_multiple_source",
            "data",
            "metadata.json",
        )
        # FIXME: This check should find the metadata file
        self.assertFalse(os.path.exists(metadata_file))
        # FIXME: This line should be in the metadata file
        if os.path.exists(metadata_file):
            self.assertEqual(
                self.grep_file(
                    metadata_file,
                    r"\"action_num\": 2,",
                ),
                [],
            )


if __name__ == "__main__":
    unittest.main(buffer=True)
