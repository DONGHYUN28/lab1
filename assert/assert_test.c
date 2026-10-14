#include <stdio.h>
#include <stdlib.h>
#include "my_assert.h"

static void foo(int num) {
    my_assert((num >= 0) && (num <= 100));
    printf("foo: num = %d\n", num);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: assert_test aNumber\n"
                        "(0 <= aNumber <= 100)\n");
        return EXIT_FAILURE;
    }
    int num = atoi(argv[1]);
    foo(num);
    return EXIT_SUCCESS;
}
