#!/usr/bin/env bash
for ((row=5; row>=1; row--)); do
    for ((col=1; col<=row; col++)); do
        printf "*"
    done
    printf "\n"
done
