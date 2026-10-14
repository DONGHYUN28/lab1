#!/usr/bin/env bash
# Ubuntu/WSL: run commands for report figures 1-18; keep real output logs.
set -uo pipefail
ROOT=$(cd -- "$(dirname -- "$0")" && pwd)
cd "$ROOT" || exit 1
RUN_STAMP=$(date +%Y%m%d_%H%M%S)_$$
RUN_DIR="$ROOT/results/$RUN_STAMP"
mkdir -p "$RUN_DIR" docs/captures practice || exit 1
# Only this runner's child processes have core dumps disabled.
ulimit -c 0 2>/dev/null || true

run() {
    printf '\n$'
    printf ' %q' "$@"
    printf '\n'
    "$@"
    local status=$?
    if ((status != 0)); then
        printf '[종료 코드: %d]\n' "$status"
    fi
    return "$status"
}

need() {
    local name missing=''
    for name in "$@"; do
        command -v "$name" >/dev/null 2>&1 || missing="$missing $name"
    done
    if [[ -n "$missing" ]]; then
        printf '[미설치 도구]%s\n' "$missing" >&2
        printf '먼저 bash setup_ubuntu.sh 를 실행한 뒤 다시 선택하세요.\n' >&2
        return 2
    fi
}

expect_abort() {
    run "$@"
    local status=$?
    if ((status == 134)); then
        printf '[확인] 단언 실패로 SIGABRT 종료(코드 134).\n'
        return 0
    fi
    printf '[불일치] 단언 실패의 예상 종료 코드 134, 실제 %d.\n' "$status" >&2
    return 1
}

title() {
    printf '\n========== %s ==========\n' "$1"
}

demo() {
    local id=$1 tool src pattern n project backup rows
    case "$id" in
    00)
        run bash setup_ubuntu.sh
        ;;
    01)
        title '그림 1 / 보고서 3쪽: 정규표현식 12종'
        need grep find || return
        run nl -ba sample/regex.txt || return
        n=0
        while IFS= read -r pattern; do
            n=$((n+1))
            printf '\n[정규표현식 %d]\n' "$n"
            run env LC_ALL=C grep -En "$pattern" sample/regex.txt || return
        done < sample/regex_patterns.txt
        run find . -maxdepth 2 -type f -name '*.c' || return
        run find . -regextype posix-extended -maxdepth 2 -type f -regex '.*\.c' || return
        printf '\n확인 기준: 각 표현식에 일치한 실제 줄과 줄 번호를 비교한다.\n'
        ;;
    02)
        title '그림 2 / 보고서 8쪽: Ubuntu와 도구 버전'
        run date '+%Y-%m-%d %H:%M:%S %Z' || return
        run cat /etc/os-release || return
        run uname -a || return
        for tool in bash gcc make git gdb valgrind; do
            printf '\n$ %s --version\n' "$tool"
            if command -v "$tool" >/dev/null 2>&1; then
                "$tool" --version 2>&1 | sed -n '1p'
            else
                printf '[미설치: %s]\n' "$tool"
            fi
        done
        ;;
    03)
        title '그림 3 / 보고서 8쪽: vi 편집과 기본 명령'
        printf '먼저 다른 Ubuntu 터미널에서 다음 명령을 실행하세요.\n'
        printf 'cd %q\nvi practice/hello.txt\n' "$ROOT"
        printf 'i → Hello Linux 입력 → Esc → :wq → Enter\n'
        if [[ ! -t 0 ]]; then
            printf '[직접 실습 필요] vi 저장 뒤 메뉴 3을 다시 실행하세요.\n'
            return 3
        fi
        read -r -p 'vi로 저장을 마쳤으면 Enter: ' _
        run cat practice/hello.txt || return
        run cp practice/hello.txt practice/copy.txt || return
        run mv practice/copy.txt practice/renamed.txt || return
        run ls -l practice/hello.txt practice/renamed.txt || return
        run grep -n Linux practice/hello.txt || return
        run find practice -type f -name '*.txt' || return
        run rm practice/renamed.txt || return
        run ls -l practice/hello.txt || return
        ;;
    04)
        title '그림 4 / 보고서 9쪽: .bashrc와 실제 쉘 설정'
        backup="$HOME/.bashrc.lab1.$RUN_STAMP.bak"
        printf '다른 Ubuntu 터미널에서 아래 순서대로 진행하세요.\n'
        printf 'cp -p %q %q\nvi %q\n' "$HOME/.bashrc" "$backup" "$HOME/.bashrc"
        printf 'sample/bashrc_lab.txt의 내용을 .bashrc 마지막에 직접 추가하세요.\n'
        run cat sample/bashrc_lab.txt || return
        printf '\n저장 후 실행: source ~/.bashrc\n'
        printf 'alias ll; ll; echo "$HISTSIZE"; echo "$HISTFILESIZE"; history | tail -5\n'
        printf '그림 4에는 그 터미널의 변경된 프롬프트도 함께 캡처하세요.\n'
        if [[ ! -t 0 ]]; then
            printf '[직접 실습 필요] .bashrc 편집은 자동으로 수행하지 않습니다.\n'
            return 3
        fi
        read -r -p '.bashrc 수정과 source를 마쳤으면 Enter: ' _
        run bash --rcfile "$HOME/.bashrc" -ic \
            'alias ll; alias cls; declare -p PS1; printf "HISTSIZE=%s\nHISTFILESIZE=%s\n" "$HISTSIZE" "$HISTFILESIZE"; history -r; history | tail -5'
        ;;
    05)
        title '그림 5 / 보고서 9쪽: ls를 사용한 파일 개수'
        project="$RUN_DIR/count_test"
        run mkdir -p "$project/folder" || return
        run touch "$project/a.txt" "$project/b.txt" "$project/c.txt" || return
        (
            cd "$project" || exit 1
            run ls -1p || exit
            run bash "$ROOT/scripts/count_files.sh" || exit
        ) || return
        printf '\n확인 기준: File count: 3 (디렉토리 제외).\n'
        ;;
    06)
        title '그림 6 / 보고서 10쪽: for, while, until 구구단'
        for src in for while until; do
            run bash "scripts/table_$src.sh" > "$RUN_DIR/table_$src.txt" || return
            run cat "$RUN_DIR/table_$src.txt" || return
            rows=$(grep -c '^[2-9] x [1-9] = ' "$RUN_DIR/table_$src.txt") || return
            printf '[실제 구구단 줄 수] %s\n' "$rows"
            if [[ "$rows" != 72 ]]; then
                printf '[불일치] 구구단은 72줄이어야 합니다.\n' >&2
                return 1
            fi
        done
        # run() prints the same-length command header but different filenames;
        # compare only program output for the three implementations.
        for src in for while until; do
            grep '^[2-9] x [1-9] = ' "$RUN_DIR/table_$src.txt" \
                > "$RUN_DIR/table_$src.out" || return
        done
        run cmp "$RUN_DIR/table_for.out" "$RUN_DIR/table_while.out" || return
        run cmp "$RUN_DIR/table_for.out" "$RUN_DIR/table_until.out" || return
        printf '\n[확인] 세 반복문의 실제 출력이 같고 각각 72줄입니다.\n'
        printf '캡처에는 세 스크립트의 명령·줄 수와 마지막 9단을 포함하세요.\n'
        ;;
    07)
        title '그림 7 / 보고서 11쪽: let 피보나치 수열'
        run bash scripts/fibonacci.sh || return
        printf '\n확인 기준: 0 1 1 2 3 5 8 13 21 34\n'
        ;;
    08)
        title '그림 8 / 보고서 11쪽: 별 개수 감소'
        run bash scripts/stars.sh || return
        printf '\n확인 기준: 첫 줄 별 5개, 마지막 줄 별 1개, 총 5줄.\n'
        ;;
    09)
        title '그림 9 / 보고서 13쪽: 정적 라이브러리'
        need gcc ar || return
        for src in add subtract multiply divide; do
            run gcc -std=c11 -Wall -Wextra -g -O0 -fPIC -Ilib \
                -c "lib/$src.c" -o "lib/$src.o" || return
        done
        run ar rcs lib/libcalc.a lib/add.o lib/subtract.o lib/multiply.o lib/divide.o || return
        run gcc -std=c11 -Wall -Wextra -g -O0 -Ilib -c main.c -o main.o || return
        run gcc main.o lib/libcalc.a -o main_static || return
        run ar t lib/libcalc.a || return
        run ./main_static || return
        ;;
    10)
        title '그림 10 / 보고서 13쪽: 공유 라이브러리'
        need gcc make ldd || return
        run make --no-print-directory lib/libcalc.so main.o || return
        run gcc main.o -Llib -lcalc '-Wl,-rpath,$ORIGIN/lib' -o main_shared || return
        run ./main_shared || return
        run ldd ./main_shared || return
        printf '\n확인 기준: libcalc.so의 실제 검색 경로가 lib 폴더입니다.\n'
        ;;
    11)
        title '그림 11 / 보고서 14쪽: dlopen과 dlsym'
        need gcc make || return
        run make --no-print-directory main_dynamic || return
        run ./main_dynamic || return
        printf '\n확인 기준: 그림 9·10과 네 사칙연산 값이 같습니다.\n'
        ;;
    12)
        title '그림 12 / 보고서 15쪽: Makefile 재빌드와 clean'
        need gcc make ar || return
        run make --no-print-directory clean || return
        run make --no-print-directory || return
        title '수정 없이 두 번째 make'
        run make --no-print-directory || return
        title 'add.c의 수정 시각 변경 뒤 make'
        run touch lib/add.c || return
        run make --no-print-directory || return
        title 'clean 이후 재빌드'
        run make --no-print-directory clean || return
        run make --no-print-directory || return
        ;;
    13)
        title '그림 13 / 보고서 16쪽: Git과 GitHub'
        need git || return
        if [[ ! -d .git && ! -f .git ]]; then
            printf 'README.md의 Git 절차로 이 lab2 폴더를 먼저 저장소로 만드세요.\n'
            printf '본인 이메일·GitHub 계정명으로 설정하고 실제로 push해야 합니다.\n'
            printf '[직접 실습 필요] 아직 이 폴더에는 Git 저장소가 없습니다.\n'
            return 3
        fi
        run git status --short --branch || return
        run git log -5 --oneline || return
        run git remote -v || return
        printf '\n본인 GitHub lab2 저장소의 파일 목록을 별도로 캡처하세요.\n'
        printf '위 출력은 로컬 상태이며 원격 업로드 성공 여부는 웹에서 확인합니다.\n'
        ;;
    14)
        title '그림 14 / 보고서 17쪽: GDB 중단점·인자·호출 스택'
        need gcc make gdb || return
        run make --no-print-directory main_static || return
        run gdb -q --batch -x debug/gdb_capture.gdb ./main_static || return
        printf '\n확인 기준: add에서 a=10, b=3, add→main 호출 관계.\n'
        ;;
    15)
        title '그림 15 / 보고서 18쪽: VSCode 실제 디버깅'
        need gcc make || return
        run make --no-print-directory all || return
        printf '이 lab2 폴더에서 code . 를 실행하세요.\n'
        printf 'WSL 환경의 C/C++ 확장을 설치하고 lib/add.c에 중단점을 지정하세요.\n'
        printf 'F5 → Debug main_static → VARIABLES a=10, b=3 확인.\n'
        printf 'CALL STACK의 add/main, F10 단계 실행과 실행 결과를 직접 캡처하세요.\n'
        printf '.vscode/tasks.json과 launch.json이 포함되어 있습니다.\n'
        printf '[직접 실습 필요] 터미널 안내 출력은 VSCode 캡처를 대신하지 않습니다.\n'
        return 3
        ;;
    16)
        title '그림 16 / 보고서 19~20쪽: my_assert 정상·실패·NDEBUG'
        need gcc make || return
        run make --no-print-directory assertions || return
        run ./assert_demo || return
        expect_abort ./assert_demo fail || return
        run ./assert_demo_ndebug fail || return
        title '강의자료 assert_test.c에 my_assert 적용'
        run ./assert_test 10 || return
        expect_abort ./assert_test 1234 || return
        run ./assert_test_ndebug 1234 || return
        printf '\n확인 기준: 정상 출력, 조건 실패, NDEBUG에서 검사 생략을 비교합니다.\n'
        ;;
    17)
        title '그림 17 / 보고서 21쪽: gprof 호출 기록'
        need gcc make gprof || return
        run make --no-print-directory profile || return
        run ./main_profile || return
        printf '\n$ gprof ./main_profile gmon.out > gprof.txt\n'
        gprof ./main_profile gmon.out > gprof.txt || return
        run head -40 gprof.txt || return
        run cp gprof.txt "$RUN_DIR/gprof.txt" || return
        printf '\n확인 기준: 함수별 호출 횟수. 짧은 실행의 시간 값은 0일 수 있습니다.\n'
        ;;
    18)
        title '그림 18 / 보고서 21쪽: Valgrind 세 방식 검사'
        need gcc make valgrind || return
        run make --no-print-directory main_static main_shared main_dynamic || return
        for src in main_static main_shared main_dynamic; do
            run valgrind --leak-check=full --show-leak-kinds=all \
                --errors-for-leak-kinds=definite,indirect --error-exitcode=1 \
                "./$src" || return
        done
        printf '\n확인 기준: 세 방식의 ERROR SUMMARY와 실제 누수 상태를 각각 기록합니다.\n'
        ;;
    19)
        title '추가 실습 / 보고서 6쪽: RCS 리비전'
        need ci co rcsdiff rlog || return
        project="$RUN_DIR/rcs_demo"
        run mkdir -p "$project/RCS" || return
        (
            cd "$project" || exit 1
            printf 'version 1\n' > note.txt
            run ci -u '-t-RCS practice' '-mfirst revision' note.txt || exit
            run co -l note.txt || exit
            printf 'version 2\n' >> note.txt
            run rcsdiff note.txt
            local rc=$?
            if ((rc != 1)); then
                printf 'rcsdiff 예상 코드 1(차이 있음), 실제 %d\n' "$rc"
                exit 1
            fi
            printf '[확인] rcsdiff 코드 1은 두 파일의 차이가 있다는 뜻입니다.\n'
            run ci -u '-msecond revision' note.txt || exit
            run rlog note.txt || exit
        ) || return
        ;;
    20)
        title '추가 실습 / 보고서 6쪽: GNU Autotools'
        need gcc make autoreconf autoconf automake libtoolize || return
        project="$RUN_DIR/autotools_demo"
        run mkdir -p "$project" || return
        run cp tools/autotools/configure.ac tools/autotools/Makefile.am \
            tools/autotools/hello.c "$project/" || return
        (
            cd "$project" || exit 1
            run autoreconf -fi || exit
            run ./configure || exit
            run make || exit
            run ./hello || exit
        ) || return
        ;;
    21)
        title '추가 실습 / 보고서 7쪽: CMake'
        need cmake gcc || return
        run cmake -S . -B build || return
        run cmake --build build || return
        run ./build/calc_demo || return
        ;;
    *)
        printf '번호는 0~21을 선택하세요.\n' >&2
        return 1
        ;;
    esac
}

capture() {
    local id=$1 status log
    log="$RUN_DIR/figure_$id.log"
    (
        printf 'Lab1 실제 실행 기록 / 항목 %s\n' "$id"
        printf '실행 시각: '; date '+%Y-%m-%d %H:%M:%S %Z'
        printf '작업 폴더: %s\n' "$ROOT"
        demo "$id"
    ) 2>&1 | tee -a "$log"
    status=$?
    printf '\n[기록 위치] %s\n' "$log"
    if ((status == 0)); then
        printf '[항목 실행 완료] 실제 결과를 확인한 뒤 화면을 캡처하세요.\n'
    elif ((status == 3)); then
        printf '[직접 진행할 항목] 위 안내에 따라 실제 화면을 준비하세요.\n'
    else
        printf '[항목 미완료] 종료 코드 %d. 오류 또는 미설치 도구를 확인하세요.\n' "$status"
    fi
    printf '%s\t%s\n' "$id" "$status" >> "$RUN_DIR/status.tsv"
    return "$status"
}

run_all() {
    local id failures=0
    for id in 01 02 05 06 07 08 09 10 11 12 14 16 17 18 19 20 21; do
        capture "$id" || failures=$((failures+1))
        if [[ -t 0 ]]; then
            read -r -p '화면을 캡처한 뒤 Enter로 다음 항목 진행: ' _
        fi
    done
    printf '\n직접 진행: 3 vi / 4 .bashrc / 13 GitHub / 15 VSCode.\n'
    printf '완료되지 않은 자동 항목: %d\n전체 기록: %s\n' "$failures" "$RUN_DIR"
    ((failures == 0))
}

menu() {
    cat <<'MENU'

Lab1 캡처용 실습 메뉴 (그림 번호와 동일)
  1 정규표현식         2 환경·도구 버전
  3 vi·기본 명령       4 .bashrc 설정
  5 파일 개수          6 구구단 세 반복문
  7 피보나치           8 별 출력
  9 정적 라이브러리   10 공유 라이브러리
 11 동적 로딩         12 Makefile
 13 Git·GitHub        14 GDB
 15 VSCode            16 my_assert
 17 gprof             18 Valgrind
추가: 19 RCS / 20 Autotools / 21 CMake
  0 Ubuntu 도구 설치 / a 자동 항목 순서대로 / q 종료
MENU
}

if (($# > 0)); then
    case "$1" in
    all|a) run_all; exit $? ;;
    *)
        if [[ "$1" =~ ^[0-9]{1,2}$ ]]; then
            id=$(printf '%02d' "$((10#$1))")
            capture "$id"
            exit $?
        fi
        printf '사용법: bash run_capture.sh [1~21|all]\n' >&2
        exit 1
        ;;
    esac
fi

while true; do
    menu
    read -r -p '실행할 번호: ' choice || break
    case "$choice" in
    q|Q) break ;;
    a|all) run_all || true ;;
    *)
        if [[ "$choice" =~ ^[0-9]{1,2}$ ]]; then
            id=$(printf '%02d' "$((10#$choice))")
            capture "$id" || true
        else
            printf '번호, a 또는 q를 입력하세요.\n'
        fi
        ;;
    esac
    read -r -p '캡처를 마쳤으면 Enter로 메뉴 복귀: ' _ || break
done
printf '\n실행 기록: %s\n' "$RUN_DIR"

