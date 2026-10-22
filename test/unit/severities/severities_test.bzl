# Copyright 2026 Ericsson AB
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Macro for testing common.check_results() severity filtering.

Each severities_test() generates a local py_test that runs
common.check_results() on a result.txt produced by a codechecker_test
"producer" (see producers/BUILD) and asserts whether the given severities (or
checker names) make the analysis pass or fail. Using a producer means the test
always runs against freshly generated analyzer output.

Example:
    severities_test(
        name = "high_severity_fails_on_high_defect",
        producer = "producers:high",
        severities = ["HIGH"],
        expect = "fail",
    )
"""

load("@rules_python//python:py_test.bzl", "py_test")

def severities_test(
        name,
        producer,
        expect,
        severities = None,
        tags = [],
        size = "small",
        **kwargs):
    """Generate a py_test driving common.check_results() on a producer's output.

    Args:
        name: Test name.
        producer: Label of a per_file codechecker_test whose generated
                  result.txt is checked. Its "<producer>/result.txt" output is
                  read by the test.
        expect: Expected outcome, either "pass" (no defects of the requested
                severities) or "fail" (defects found).
        severities: List of severities and/or checker (bug) names to fail on,
                    e.g. ["HIGH", "core.DivideZero"]. None (the default)
                    passes no severities, which check_results() treats as
                    invalid input. An empty list [] passes an empty set, which
                    check_results() defaults to HIGH.
        tags: Additional test tags.
        size: Test size (default: small).
        **kwargs: Forwarded to py_test.
    """
    if expect not in ["pass", "fail"]:
        fail("severities_test expect must be 'pass' or 'fail', got: " + expect)
    if severities != None and type(severities) != "list":
        fail("severities_test severities must be a list or None, got: " +
             str(severities))

    # The producer label may be written relative to this package,
    # e.g. "producers:high", but we need an absolute label.
    if producer.startswith("//") or producer.startswith("@"):
        result_txt = "%s/codechecker-files/result.txt" % producer
    else:
        result_txt = "//%s/%s/codechecker-files/result.txt" % (native.package_name(), producer)

    args = [
        "--file=$(location {})".format(result_txt),
        "--expect={}".format(expect),
    ]

    # Match how codechecker.bzl passes severities to its launcher.
    if severities != None:
        args.append("--severities='{}'".format(" ".join(severities)))

    py_test(
        name = name,
        srcs = ["severities_check.py"],
        main = "severities_check.py",
        args = args,
        data = [result_txt],
        local = True,
        tags = ["unit"] + tags,
        size = size,
        deps = ["//src:common"],
        **kwargs
    )
