#include <stdio.h>
#include "my_assert.h"

int main(int argc, char **argv) {
    (void)argv;
    int value = (argc > 1) ? 0 : 3;
    my_assert(value > 0);
    puts("Assertion test passed.");
    return 0;
}
