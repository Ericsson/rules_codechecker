#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")
ARGUMENTS="$@"

function log {
    echo "===================================================================="
    echo "=== $@"
    echo "===================================================================="
}

function run {
    local command="$@"
    log "Running: ${command}"
    eval ${command}
}

log "Initializing micromamba: ${ARGUMENTS}"
source $SCRIPT_DIR/init.sh ${ARGUMENTS}
cd $SCRIPT_DIR/../..

run "bazel version"
run "bazel clean"
run "CodeChecker version"
run "pylint ."
run "bazel test ..."
run "pytest test"
run "micromamba deactivate"
