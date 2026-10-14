cmake_minimum_required(VERSION 3.16)
project(lab2 LANGUAGES C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
add_library(calc STATIC
    lib/add.c lib/subtract.c lib/multiply.c lib/divide.c)
target_include_directories(calc PUBLIC lib)
add_executable(calc_demo main.c)
target_link_libraries(calc_demo PRIVATE calc)
