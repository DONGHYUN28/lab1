#include <stdio.h>
#include <stdlib.h>
#include "calc.h"

int main(void) {
    double a = 10.0, b = 3.0;
    double *result = malloc(4 * sizeof(*result));
    if (result == NULL) {
        perror("malloc");
        return EXIT_FAILURE;
    }
    result[0] = add(a, b);
    result[1] = subtract(a, b);
    result[2] = multiply(a, b);
    result[3] = divide(a, b);
    printf("add(10,3) = %.2f\n", result[0]);
    printf("subtract(10,3) = %.2f\n", result[1]);
    printf("multiply(10,3) = %.2f\n", result[2]);
    printf("divide(10,3) = %.2f\n", result[3]);
    free(result);
    return EXIT_SUCCESS;
}
