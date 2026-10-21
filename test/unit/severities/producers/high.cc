// Produces a single HIGH defect: division by zero triggers core.DivideZero
// (HIGH).
int high_only() {
    int a = 0;
    int b = 0 / a;
    return b;
}
