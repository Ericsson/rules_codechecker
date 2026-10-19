// Copyright 2026 Ericsson AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Produces only a LOW defect: a value stored into a local is overwritten
// before it is ever read, triggering deadcode.DeadStores (LOW). The variable
// is read afterwards, so it is not an unused variable (no MEDIUM), and nothing
// produces a HIGH defect.
int low_only(int input) {
    int value;
    value = input + 1;    // Dead store: overwritten below before any read.
    value = input * 2;
    return value;
}
