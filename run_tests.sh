#!/usr/bin/env bash
echo "Initialize micromamba environment..."
source ./.ci/micromamba/init.sh

echo "Running pylint..."
pylint .
echo "Running bazel test //..."
bazel test //...
echo "Running pytest ..."
pytest test

echo "Exiting micromamba..."
micromamba deactivate
