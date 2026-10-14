#!/usr/bin/env bash
for dan in {2..9}; do
    for n in {1..9}; do
        printf "%d x %d = %d\n" "$dan" "$n" "$((dan*n))"
    done
done
