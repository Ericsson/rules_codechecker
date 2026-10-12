#!/bin/bash
# Verify that a file contains every expected pattern
#
# Usage: check.sh FILE PATTERN...
set -euo pipefail

file="$1"
shift

for pattern in "$@"; do
    if ! grep -qE "$pattern" "$file"; then
        echo "FAIL: '$pattern' not found in $file"
        exit 1
    fi
done

echo "PASS"
