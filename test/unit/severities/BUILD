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

# Every fixture below lives in fixtures/ and comes as a pair: a result_*.txt
# that check_results() reads, and a result_*.json of the same analysis.
#
#   result_clean.txt / .json         no defects
#   result_low.txt / .json           one LOW defect: deadcode.DeadStores
#   result_medium.txt / .json        one MEDIUM defect:
#   result_high.txt / .json          one HIGH defect: core.DivideZero
#   result_critical.txt / .json      one CRITICAL defect:
#   result_multi.txt / .json         HIGH, MEDIUM and LOW defects across
#                                    several checkers, e.g. core.DivideZero
#                                    (HIGH), clang-diagnostic-unused-variable
#                                    (MEDIUM), deadcode.DeadStores (LOW)

severities_test(
    name = "clean_results_pass",
    expect = "pass",
    file = "fixtures/result_clean.txt",
    severities = [
        "LOW",
        "MEDIUM",
        "HIGH",
    ],
)

severities_test(
    name = "high_severity_fails_on_high_defect",
    expect = "fail",
    file = "fixtures/result_high.txt",
    severities = ["HIGH"],
)

severities_test(
    name = "non_high_severities_pass_on_high_defect",
    expect = "pass",
    file = "fixtures/result_high.txt",
    severities = [
        "LOW",
        "MEDIUM",
    ],
)

severities_test(
    name = "empty_severities_defaults_to_high",
    expect = "fail",
    file = "fixtures/result_high.txt",
    severities = [],
)

severities_test(
    name = "low_severity_fails_on_low_defect",
    expect = "fail",
    file = "fixtures/result_low.txt",
    severities = ["LOW"],
)

severities_test(
    name = "unmatched_severity_passes",
    expect = "pass",
    file = "fixtures/result_multi.txt",
    severities = ["IDONTEXIST"],
)

severities_test(
    name = "multiple_severities_fail",
    expect = "fail",
    file = "fixtures/result_multi.txt",
    severities = [
        "LOW",
        "MEDIUM",
        "HIGH",
    ],
)

severities_test(
    name = "medium_severity_fails_on_medium_defect",
    expect = "fail",
    file = "fixtures/result_medium.txt",
    severities = ["MEDIUM"],
)

severities_test(
    name = "high_severity_passes_on_medium_defect",
    expect = "pass",
    file = "fixtures/result_medium.txt",
    severities = ["HIGH"],
)

severities_test(
    name = "low_severity_passes_on_medium_defect",
    expect = "pass",
    file = "fixtures/result_medium.txt",
    severities = ["LOW"],
)

severities_test(
    name = "high_severity_passes_on_low_defect",
    expect = "pass",
    file = "fixtures/result_low.txt",
    severities = ["HIGH"],
)

severities_test(
    name = "medium_severity_passes_on_low_defect",
    expect = "pass",
    file = "fixtures/result_low.txt",
    severities = ["MEDIUM"],
)

severities_test(
    name = "critical_severity_fails_on_critical_defect",
    expect = "fail",
    file = "fixtures/result_critical.txt",
    severities = ["CRITICAL"],
)

# A CRITICAL defect always fails
severities_test(
    name = "critical_defect_fails_on_unrelated_severity",
    expect = "fail",
    file = "fixtures/result_critical.txt",
    severities = ["LOW"],
)

severities_test(
    name = "critical_defect_fails_on_empty_severities",
    expect = "fail",
    file = "fixtures/result_critical.txt",
    severities = [],
)

# --- Bug name based filtering ------------------------------------------------
# Users may pass a checker/bug name instead of a severity.
# e.g. "core.DivideZero".

severities_test(
    name = "bug_name_fails_when_present",
    expect = "fail",
    file = "fixtures/result_high.txt",
    severities = ["core.DivideZero"],
)

severities_test(
    name = "bug_name_passes_when_absent",
    expect = "pass",
    file = "fixtures/result_high.txt",
    severities = ["cplusplus.NewDeleteLeaks"],
)

severities_test(
    name = "bug_name_in_multi_fixture_fails",
    expect = "fail",
    file = "fixtures/result_multi.txt",
    severities = ["clang-diagnostic-unused-variable"],
)

severities_test(
    name = "mixed_severity_and_bug_name_fails",
    expect = "fail",
    file = "fixtures/result_multi.txt",
    severities = [
        "core.DivideZero",
    ],
)
