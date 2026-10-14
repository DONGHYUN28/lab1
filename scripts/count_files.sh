#!/usr/bin/env bash
# Count visible non-directory entries; test with simple file names.
count=$(ls -1p | grep -v '/$' | wc -l)
printf "File count: %d\n" "$count"
