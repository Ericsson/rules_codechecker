# CI Docker Images

These Dockerfiles allows you to test the rules set in a sandbox environment.

## Quick Start

```bash
# Build
docker build -t codechecker-bazel-ubuntu .ci/docker/ubuntu/
docker build -t codechecker-bazel-rhel9  .ci/docker/rhel9/
```
If you encounter network related issues try passing the flag: `--network=host`.

# Run tests against the project (mount project root to /workspace)

```bash
docker run --rm \
    -v "$(pwd):/workspace" \
    codechecker-bazel-ubuntu

docker run --rm \
    -v "$(pwd):/workspace" \
    codechecker-bazel-rhel9
```
