#!/usr/bin/env bash

cleanup() {
    # Very important
    # reactivation of the mamba environment is not possible if skipped
    bazel clean
    micromamba deactivate
}

trap cleanup EXIT

source ./.ci/micromamba/init.sh

pylint .
bazel test //...
pytest test
