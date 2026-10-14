CC = gcc
AR = ar
CPPFLAGS = -Ilib
CFLAGS = -std=c11 -Wall -Wextra -g -O0 -fPIC
LIBSRC = lib/add.c lib/subtract.c lib/multiply.c lib/divide.c
LIBOBJ = $(LIBSRC:.c=.o)

.PHONY: all clean profile assertions
all: main_static main_shared main_dynamic assert_demo

lib/%.o: lib/%.c lib/calc.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

main.o: main.c lib/calc.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

main_dl.o: main_dl.c
	$(CC) $(CFLAGS) -c $< -o $@

lib/libcalc.a: $(LIBOBJ)
	$(AR) rcs $@ $^

lib/libcalc.so: $(LIBOBJ)
	$(CC) -shared -o $@ $^

main_static: main.o lib/libcalc.a
	$(CC) -o $@ $^

main_shared: main.o lib/libcalc.so
	$(CC) -o $@ main.o -Llib -lcalc -Wl,-rpath,'$$ORIGIN/lib'

main_dynamic: main_dl.o lib/libcalc.so
	$(CC) -o $@ main_dl.o -ldl

assert_demo: assert/assert_demo.c assert/my_assert.h
	$(CC) $(CFLAGS) -Iassert $< -o $@

assert_test: assert/assert_test.c assert/my_assert.h
	$(CC) $(CFLAGS) -Iassert $< -o $@

assert_demo_ndebug: assert/assert_demo.c assert/my_assert.h
	$(CC) -std=c11 -g -O0 -DNDEBUG -Iassert $< -o $@

assert_test_ndebug: assert/assert_test.c assert/my_assert.h
	$(CC) -std=c11 -g -O0 -DNDEBUG -Iassert $< -o $@

assertions: assert_demo assert_test assert_demo_ndebug assert_test_ndebug

profile: main_profile

main_profile: main.c $(LIBSRC) lib/calc.h
	$(CC) $(CPPFLAGS) -std=c11 -Wall -Wextra -g -O0 -pg \
	    main.c $(LIBSRC) -o $@

clean:
	rm -f main.o main_dl.o $(LIBOBJ) lib/libcalc.a lib/libcalc.so
	rm -f main_static main_shared main_dynamic assert_demo main_profile
	rm -f assert_test assert_demo_ndebug assert_test_ndebug assert_ndebug
	rm -f gmon.out gprof.txt
