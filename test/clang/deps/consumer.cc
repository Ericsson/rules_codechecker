// Both headers are found through the include paths of the dependencies:
// a public one from deps and a private one from implementation_deps
#include "private.h"
#include "public.h"

int consumer() {
    return public_value() + private_value();
}
