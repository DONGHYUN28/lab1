#!/usr/bin/env bash
a=0
b=1
for ((i=0; i<10; i++)); do
    printf "%d " "$a"
    let "next=a+b"
    a=$b
    b=$next
done
printf "\n"
