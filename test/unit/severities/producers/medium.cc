// Produces only a MEDIUM defect: an unused local variable triggers
// clang-diagnostic-unused-variable (MEDIUM).
int medium_only() {
    int unused = 42;
    return 0;
}
