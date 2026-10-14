#!/usr/bin/env bash
dan=2
while ((dan <= 9)); do
    n=1
    while ((n <= 9)); do
        printf "%d x %d = %d\n" "$dan" "$n" "$((dan*n))"
        ((n++))
    done
    ((dan++))
done
