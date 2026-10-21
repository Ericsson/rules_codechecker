// Produces only a CRITICAL defect: returning an int where an int* is expected
// is a hard error, reported as clang-diagnostic-error which CodeChecker maps
// to the CRITICAL severity.
int *critical_only() {
    int local = 0;
    return local;  // error: cannot initialize return object of type 'int *'
}
