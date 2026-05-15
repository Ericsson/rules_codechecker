#!/usr/bin/env bash
echo "Clean up previous micromamba environment"
chmod -R +w .ci/micromamba/micromamba/envs/dev
rm -rf .ci/micromamba/micromamba/envs/dev

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
