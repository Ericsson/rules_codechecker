# CI Docker Images

These Dockerfiles allows you to test the rules set in a sandbox environment.
Each Dockerfile has its own folder with the name of the distribution its based on.
The `entrypoint.sh` script stores the commands for running tests, and wil be executed when running the images with `docker run`.

## Quick Start

```bash
# Build
docker build -t codechecker-bazel-ubuntu -f .ci/docker/ubuntu/Dockerfile .ci/docker
docker build -t codechecker-bazel-rhel9  -f .ci/docker/rhel9/Dockerfile .ci/docker
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
