// Produces only a LOW defect: a value stored into a local is overwritten
// before it is ever read, triggering deadcode.DeadStores (LOW).
int low_only(int input) {
    int value;
    value = input + 1;    // Dead store: overwritten below before any read.
    value = input * 2;
    return value;
}
