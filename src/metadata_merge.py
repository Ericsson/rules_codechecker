# Copyright 2023 Ericsson AB
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
Merges the metadata information of multiple CodeChecker analysis.
"""

import json
import os
import sys
from typing import List, Dict, Any


# Structure of metadata files is defined here:
# https://github.com/Ericsson/codechecker/blob/master/docs/report_directory.md#metadata-structure

def _merge_analyzer_statistics(stat1, stat2):
    """
    Merges two analyzer_statistics dicts into stat1.

    Sums failed/successful counts, extends source lists,
    and preserves the version field.
    """
    stat1["failed"] = stat1["failed"] + stat2["failed"]
    stat1["failed_sources"].extend(stat2["failed_sources"])
    stat1["successful"] = stat1["successful"] + stat2["successful"]
    stat1["successful_sources"].extend(stat2["successful_sources"])


def _merge_checkers(checkers1, checkers2):
    """
    Merges two checker dicts.

    A checker is enabled (True) in the result if it is enabled
    in either input. This handles the case where different
    per-file runs may report slightly different checker sets.
    """
    for checker, enabled in checkers2.items():
        if checker not in checkers1:
            checkers1[checker] = enabled
        else:
            # If enabled in either, mark as enabled
            checkers1[checker] = checkers1[checker] or enabled


def _merge_analyzers(analyzers1, analyzers2):
    """
    Merges analyzer sections from two metadata files.

    Handles the case where json2 has analyzers not present
    in json1 by initializing them from json2.
    """
    for analyzer_name, analyzer_data in analyzers2.items():
        if analyzer_name not in analyzers1:
            # Analyzer exists in json2 but not json1; adopt it
            analyzers1[analyzer_name] = analyzer_data
            continue

        # Merge checkers
        if "checkers" in analyzer_data:
            if "checkers" not in analyzers1[analyzer_name]:
                analyzers1[analyzer_name]["checkers"] = {}
            _merge_checkers(
                analyzers1[analyzer_name]["checkers"],
                analyzer_data["checkers"],
            )

        # Merge analyzer_statistics
        if "analyzer_statistics" in analyzer_data:
            if "analyzer_statistics" not in analyzers1[analyzer_name]:
                analyzers1[analyzer_name]["analyzer_statistics"] = (
                    analyzer_data["analyzer_statistics"]
                )
            else:
                _merge_analyzer_statistics(
                    analyzers1[analyzer_name]["analyzer_statistics"],
                    analyzer_data["analyzer_statistics"],
                )


def merge_two_json(json1, json2):
    """
    Merges the data of two metadata json files.

    If both json files are empty, returns an empty json.
    Handles all fields defined in the CodeChecker metadata spec:
    - version, name, action_num, command, working_directory,
      output_path, result_source_files, analyzers (with checkers
      and analyzer_statistics including version), skipped,
      timestamps.
    """
    if json1 == {}:
        return json2
    if json2 == {}:
        return json1
    # Happens when analysis of all files was skipped
    if json1 == {} and json2 == {}:
        return {}
    # Fail if the metadata format version is not 2
    assert json1["version"] == 2
    assert json2["version"] == 2
    json1_tools = json1["tools"][0]
    json2_tools = json2["tools"][0]
    # We expect the following fields to be the same in all
    # metadata files from the same analysis invocation.
    assert json1_tools["name"] == json2_tools["name"]
    # Same CodeChecker version
    assert json1_tools["version"] == json2_tools["version"]
    # command, working_directory and output_path may differ
    # between per-file runs (e.g. remote workers). We keep
    # json1's values as the canonical ones.

    # Sum action counts and skipped files
    json1_tools["action_num"] += json2_tools["action_num"]
    json1_tools["skipped"] = json1_tools["skipped"] + json2_tools["skipped"]

    # Merge result_source_files mapping
    json1_tools["result_source_files"].update(
        json2_tools["result_source_files"]
    )

    # Merge timestamps; we assume both json files describe jobs
    # in the same analysis invocation, implying that the analysis
    # start time is the lowest timestamp, and the end is the
    # highest.
    # Note: caching will break this assumption
    # Users may see months, or even years long difference in timestamps
    json1_tools["timestamps"]["begin"] = min(
        float(json1_tools["timestamps"]["begin"]),
        float(json2_tools["timestamps"]["begin"]),
    )
    json1_tools["timestamps"]["end"] = max(
        float(json1_tools["timestamps"]["end"]),
        float(json2_tools["timestamps"]["end"]),
    )

    # Merge analyzers (checkers + analyzer_statistics)
    _merge_analyzers(
        json1_tools["analyzers"], json2_tools["analyzers"]
    )

    return json1


def merge_json_files(file_paths: List[str]) -> Dict[str, Any]:
    """
    Merges a list of metadata.json files, using merge_two_json.

    Returns the merged contents of the json files.
    """
    merged_data = {}
    for file_path in file_paths:
        if not os.path.exists(file_path):
            print(
                f"Error: File not found at '{file_path}'. Skipping.",
                file=sys.stderr,
            )
            continue

        try:
            with open(file_path, "r", encoding="utf-8") as f:
                data = json.load(f)
                merged_data = merge_two_json(merged_data, data)
        except json.JSONDecodeError:
            print(
                f"Error: Could not decode JSON from '{file_path}'. Skipping.",
                file=sys.stderr,
            )

    return merged_data

def main():
    """
    Main function of metadata merge
    """
    output_file = sys.argv[1]
    input_files = sys.argv[2:]

    merged_data = merge_json_files(input_files)
    if merged_data:
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(merged_data, f, indent=4)
    else:
        print("\nNo data was merged. Output file will not be created.")


if __name__ == "__main__":
    main()
