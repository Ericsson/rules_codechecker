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
Codechecker server functionality, and related functions
"""

import os
import shutil
import signal
import socket
import subprocess
import tempfile
import time
import urllib
import urllib.request
import urllib.error


def _get_free_port():
    """
    Return a port number that is free
    """
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("", 0))
        return s.getsockname()[1]


def wait_codechecker_server(
    product: str = "Default",
    host: str = "localhost",
    port: int = 8001,
    timeout: int = 10000,
    attempt_every: int = 100,
) -> bool:
    """
    Wait until the product is available in the CodeChecker server
    """
    start = time.monotonic()
    url = f"http://{host}:{port}/{product}"
    while time.monotonic() - start < timeout:
        try:
            with urllib.request.urlopen(url, timeout=timeout / 1000) as resp:
                if resp.getcode() == 200:
                    return True
        except (urllib.error.URLError, urllib.error.HTTPError):
            pass
        time.sleep(attempt_every / 1000)
    return False


class CodeCheckerServer:
    """
    CodeCheckerServer object for testing.
    Cleans up after itself.
    """

    def __init__(self, port=None):
        self.running = False
        self.port = port if port else _get_free_port()
        self.temp_workspace = tempfile.mkdtemp()
        self.start_codechecker_server()

    def __del__(self):
        self.stop_codechecker_server()

    def start_codechecker_server(self):
        """
        Starts a CodeChecker server instance on a free port 
        This server must be shutdown with stop_codechecker_sever
        """
        if self.running:
            return
        server_command = [
            "CodeChecker",
            "server",
            "--workspace",
            self.temp_workspace,
            "--port",
            str(self.port),
        ]
        # These file/popen processes are closed when the object dies
        # pylint: disable=consider-using-with
        self.devnull = open(os.devnull, "w", encoding="utf-8")
        # pylint: disable=consider-using-with
        self.server_process: subprocess.Popen = subprocess.Popen(
            server_command, stdout=self.devnull
        )
        assert wait_codechecker_server(
            port=self.port, timeout=10000
        ), "Failed to start CodeChecker server"
        self.running = True

    def stop_codechecker_server(self):
        """
        Stops the CodeChecker server started by start_codechecker_server
        """
        os.kill(self.server_process.pid, signal.SIGTERM)
        self.server_process.wait()
        self.running = False
        self.devnull.close()
        shutil.rmtree(self.temp_workspace)
