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

load(":severities_test.bzl", "severities_test")

# Each test runs check_results() against the result.txt produced by a per_file
# codechecker_test in producers/. The producers run the real analysis on a
# crafted source, so the tests always check freshly generated analyzer output:
#
#   producers:clean      no defects
#   producers:high       one HIGH:     core.DivideZero
#   producers:medium     one MEDIUM:   clang-diagnostic-unused-variable
#   producers:low        one LOW:      deadcode.DeadStores
#   producers:critical   one CRITICAL: clang-diagnostic-error
#   producers:multi       HIGH, MEDIUM and LOW together

severities_test(
    name = "clean_results_pass",
    expect = "pass",
    producer = "producers:clean",
    severities = [
        "LOW",
        "MEDIUM",
        "HIGH",
    ],
)

severities_test(
    name = "high_severity_fails_on_high_defect",
    expect = "fail",
    producer = "producers:high",
    severities = ["HIGH"],
)

severities_test(
    name = "non_high_severities_pass_on_high_defect",
    expect = "pass",
    producer = "producers:high",
    severities = [
        "LOW",
        "MEDIUM",
    ],
)

severities_test(
    name = "empty_severities_defaults_to_high",
    expect = "fail",
    producer = "producers:high",
    severities = [],
)

severities_test(
    name = "low_severity_fails_on_low_defect",
    expect = "fail",
    producer = "producers:low",
    severities = ["LOW"],
)

severities_test(
    name = "unmatched_severity_passes",
    expect = "pass",
    producer = "producers:multi",
    severities = ["IDONTEXIST"],
)

severities_test(
    name = "multiple_severities_fail",
    expect = "fail",
    producer = "producers:multi",
    severities = [
        "LOW",
        "MEDIUM",
        "HIGH",
    ],
)

severities_test(
    name = "medium_severity_fails_on_medium_defect",
    expect = "fail",
    producer = "producers:medium",
    severities = ["MEDIUM"],
)

severities_test(
    name = "high_severity_passes_on_medium_defect",
    expect = "pass",
    producer = "producers:medium",
    severities = ["HIGH"],
)

severities_test(
    name = "low_severity_passes_on_medium_defect",
    expect = "pass",
    producer = "producers:medium",
    severities = ["LOW"],
)

severities_test(
    name = "high_severity_passes_on_low_defect",
    expect = "pass",
    producer = "producers:low",
    severities = ["HIGH"],
)

severities_test(
    name = "medium_severity_passes_on_low_defect",
    expect = "pass",
    producer = "producers:low",
    severities = ["MEDIUM"],
)

severities_test(
    name = "critical_severity_fails_on_critical_defect",
    expect = "fail",
    producer = "producers:critical",
    severities = ["CRITICAL"],
)

# A CRITICAL defect always fails
severities_test(
    name = "critical_defect_fails_on_unrelated_severity",
    expect = "fail",
    producer = "producers:critical",
    severities = ["LOW"],
)

severities_test(
    name = "critical_defect_fails_on_empty_severities",
    expect = "fail",
    producer = "producers:critical",
    severities = [],
)

# --- Bug name based filtering ------------------------------------------------
# Users may pass a checker/bug name instead of a severity.
# e.g. "core.DivideZero".

severities_test(
    name = "bug_name_fails_when_present",
    expect = "fail",
    producer = "producers:high",
    severities = ["core.DivideZero"],
)

severities_test(
    name = "bug_name_passes_when_absent",
    expect = "pass",
    producer = "producers:high",
    severities = ["cplusplus.NewDeleteLeaks"],
)

severities_test(
    name = "bug_name_in_multi_fixture_fails",
    expect = "fail",
    producer = "producers:multi",
    severities = ["clang-diagnostic-unused-variable"],
)

severities_test(
    name = "mixed_severity_and_bug_name_fails",
    expect = "fail",
    producer = "producers:multi",
    severities = [
        "core.DivideZero",
    ],
)
