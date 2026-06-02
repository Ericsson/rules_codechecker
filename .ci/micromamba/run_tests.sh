#!/usr/bin/env bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")
cd $SCRIPT_DIR

echo "Initialize micromamba environment..."
source ./init.sh

# Change directory to project root 
cd ../../

echo "Running pylint..."
pylint .
echo "Running bazel test //..."
bazel test //...
echo "Running pytest ..."
pytest test

echo "Exiting micromamba..."
micromamba deactivate
