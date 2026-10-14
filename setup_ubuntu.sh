#!/usr/bin/env bash
set -euo pipefail
if ! command -v apt >/dev/null 2>&1; then
    printf '이 설치 스크립트는 apt를 사용하는 Ubuntu/Debian용입니다.\n' >&2
    exit 1
fi
sudo apt update
sudo apt install -y build-essential gdb valgrind git binutils unzip vim \
    rcs autoconf automake libtool cmake
printf '\n설치 완료. bash run_capture.sh 로 실습 메뉴를 시작하세요.\n'
