#!/usr/bin/env bash
# This script currently assumes that the user have set up their environment.
# This means users using bazelisk have set their bazel version.
# Either with the environment variable: USE_BAZEL_VERSION
# or with the .bazelversion file.
pylint .
bazel test //...
pytest test/
