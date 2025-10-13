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
Tests regex resolution from remote executor absolute path
to local relative paths
"""
import os
import shutil
import unittest
from typing import Dict
from common.base import TestBase
from src.codechecker_script import fix_bazel_paths

PATH_RESOLUTION: Dict[str, str] = {
    # {Remote execution absolute path}: {project relative path}
    "/worker/build/5d2c60d87885b089/root/test/unit/legacy/src/lib.cc": "test/unit/legacy/src/lib.cc",
    "/worker/build/a0ed5e04f7c3b444/root/test/unit/legacy/src/ctu.cc": "test/unit/legacy/src/ctu.cc",
    "/worker/build/a0ed5e04f7c3b444/root/test/unit/legacy/src/fail.cc": "test/unit/legacy/src/fail.cc",
    # This resolution is impossible, because "test_inc" => "inc" cannot be resolved
    # "/worker/build/28e82627f5078a2d/root/bazel-out/k8-fastbuild/bin/test/unit/virtual_include/_virtual_includes/test_inc/zeroDiv.h": "test/unit/virtual_include/inc/zeroDiv.h"
}


class TestTemplate(TestBase):
    """Test regex resolution of remote execution paths"""

    # Set working directory
    __test_path__ = os.path.dirname(os.path.abspath(__file__))
    BAZEL_BIN_DIR = os.path.join(
        "../../..", "bazel-bin", "test", "unit", "plist_res"
    )
    BAZEL_TESTLOGS_DIR = os.path.join(
        "../../..", "bazel-testlogs", "test", "unit", "plist_res"
    )
    dir = os.path.dirname(os.path.abspath(__file__)) + "/tmp"

    def setUp(self):
        """Write absolute paths to action directory"""
        if os.path.exists("tmp"):
            try:
                shutil.rmtree("tmp")
            except Exception as e:
                self.fail(f"Failed to clean up the existing tmp directory {e}")
        os.mkdir("tmp")
        with open("tmp/test.txt", "w") as f:
            for abs, _ in PATH_RESOLUTION.items():
                f.write(abs + "\n")
        super().setUp()

    def tearDown(self):
        """Remove test files"""
        if os.path.exists("tmp"):
            try:
                shutil.rmtree("tmp")
            except:
                pass
        return super().tearDown()

    def test_remote_worker_path_resolution(self):
        """
        Test: Resolve absolute path of remote worker
        to a relative path of the original project
        """
        fix_bazel_paths(self.__test_path__ + "/tmp")  # type: ignore
        with open("tmp/test.txt", "r") as f:
            for _, res in PATH_RESOLUTION.items():
                # FIXME: change to assertEqual
                self.assertNotEqual(f.readline().strip(), res)


if __name__ == "__main__":
    unittest.main(buffer=True)
