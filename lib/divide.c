#include <errno.h>
#include <math.h>
#include "calc.h"
double divide(double a, double b) {
    if (b == 0.0) {
        errno = EDOM;
        return NAN;
    }
    return a / b;
}
