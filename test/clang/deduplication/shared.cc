// Defect free source shared by two libraries, to check that a source analyzed
// through more than one target does not produce conflicting analysis actions
int shared(int first, int second)
{
    return first * second;
}
