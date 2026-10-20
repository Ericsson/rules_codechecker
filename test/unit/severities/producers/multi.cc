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
