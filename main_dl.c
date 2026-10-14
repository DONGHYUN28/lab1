#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
typedef double (*operation)(double, double);

static operation load_operation(void *handle, const char *name) {
    dlerror();
    operation fn = (operation)dlsym(handle, name);
    const char *error = dlerror();
    if (error != NULL) {
        fprintf(stderr, "%s\n", error);
        dlclose(handle);
        exit(EXIT_FAILURE);
    }
    return fn;
}

int main(void) {
    void *handle = dlopen("./lib/libcalc.so", RTLD_NOW);
    if (handle == NULL) {
        fprintf(stderr, "%s\n", dlerror());
        return EXIT_FAILURE;
    }
    operation add_fn = load_operation(handle, "add");
    operation sub_fn = load_operation(handle, "subtract");
    operation mul_fn = load_operation(handle, "multiply");
    operation div_fn = load_operation(handle, "divide");
    printf("add(10,3) = %.2f\n", add_fn(10, 3));
    printf("subtract(10,3) = %.2f\n", sub_fn(10, 3));
    printf("multiply(10,3) = %.2f\n", mul_fn(10, 3));
    printf("divide(10,3) = %.2f\n", div_fn(10, 3));
    if (dlclose(handle) != 0) {
        fprintf(stderr, "%s\n", dlerror());
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
