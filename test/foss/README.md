# Add new FOSS test project:

To add a new FOSS test project, add a yaml file to this directory.
This yaml file should specify:
- **\[name\]** The name of the project.
- **\[url\]** The git url of the project.
- **\[targets\]** A list of targets to be tested.
    - \[name\] Name of the target.
- **\[version_tags\]** A list of bazel versions and project hashes to test on.
    - \[bazel_version\] The major bazel version to be tested on as a string.
    - \[hash\] The tag or commit hash to be checked out for this bazel version.
    - \[bzlmod\] Boolean wether to use the bzlmod (`MODULE.bazel`) or the legacy (`WORKSPACE`) system. (Default to False on bazel 6, 7 True on bazel 8 and onwards)
    - \[patch\] Optional cmd to run after successfully cloned and checked out the repository, and have set up targets. (Should be a list, starting with the full path of an executable, e.g. `["/usr/bin/env bash", ...]`)

For template use any of the existing project configurations.
