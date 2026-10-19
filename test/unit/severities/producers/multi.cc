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

// Produces defects of several severities in one translation unit:
//   - division by zero        -> core.DivideZero (HIGH)
//   - unused local variable    -> clang-diagnostic-unused-variable (MEDIUM)
//   - value stored, never read -> deadcode.DeadStores (LOW)
int side_effect() {
    return 7;
}

int multi() {
    int zero = 0;
    int high = 1 / zero;    // HIGH: division by zero.

    // MEDIUM (unused variable) and LOW (dead store): initialized from a call
    // but never read, mirroring the implementation_deps fixture shape.
    int unused = side_effect();

    return high;
}
