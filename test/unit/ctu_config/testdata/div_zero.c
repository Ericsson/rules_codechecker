#include "header.h"

int get0();

void f() {
  int i = get0();
  (void)(10 / i); // division by zero error
}