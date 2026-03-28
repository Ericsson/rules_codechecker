#!/usr/bin/env bash

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

# FOSS integration test runner for rules_codechecker.
#
# Environment variables:
#   FOSS_URL               - URL to the source archive
#   FOSS_BUILD             - BUILD file content for the FOSS project
#   FOSS_TARGETS           - Space-separated bazel targets to build
#   RULES_CODECHECKER_PATH - set automatically by the test runner

set -euo pipefail

# Resolve the real path to rules_codechecker workspace root
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
RULES_CODECHECKER_PATH="$(cd "$SCRIPT_DIR/../.." && pwd)"

WORK_DIR="$(mktemp -d)"

cleanup() {
    if [[ -d "$WORK_DIR" ]]; then
        cd /
        bazel --output_base="$WORK_DIR/.bazel_output" shutdown 2>/dev/null || true
        chmod -R u+w "$WORK_DIR" 2>/dev/null || true
        rm -rf "$WORK_DIR"
    fi
}
trap cleanup EXIT

echo "=== Downloading $FOSS_URL ==="
wget -q -O "$WORK_DIR/archive.tar.gz" "$FOSS_URL"
tar xzf "$WORK_DIR/archive.tar.gz" -C "$WORK_DIR" --strip-components=1

echo "=== Setting up Bazel project ==="
cd "$WORK_DIR"

# Create a subdirectory for our test targets that reference the FOSS library
mkdir -p analysis
echo "$FOSS_BUILD" > analysis/BUILD.bazel

cat > MODULE.bazel <<EOF
local_path_override(
    module_name = "rules_codechecker",
    path = "${RULES_CODECHECKER_PATH}",
)
bazel_dep(name = "rules_codechecker")
EOF

touch WORKSPACE

# Prefix targets with analysis/
PREFIXED_TARGETS=""
for t in $FOSS_TARGETS; do
    PREFIXED_TARGETS="$PREFIXED_TARGETS //analysis${t}"
done

echo "=== Running: bazel build $PREFIXED_TARGETS ==="
# shellcheck disable=SC2086
bazel --output_base="$WORK_DIR/.bazel_output" build $PREFIXED_TARGETS

echo "=== PASSED ==="
