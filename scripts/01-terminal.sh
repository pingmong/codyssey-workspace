#!/usr/bin/env bash
# 요구사항 2·3: 터미널 조작 + 권한 실습
# 실행: bash scripts/01-terminal.sh   (프로젝트 루트에서)
# 결과: logs/01-terminal.txt, logs/02-permission.txt
set -u
cd "$(dirname "$0")/.." || exit 1
mkdir -p logs
LOG=logs/01-terminal.txt
: > "$LOG"

run() {           # 명령과 출력을 함께 기록
  echo "\$ $*" | tee -a "$LOG"
  eval "$@" 2>&1 | tee -a "$LOG"
  echo | tee -a "$LOG"
}

echo "### 터미널 조작 로그 ($(date '+%Y-%m-%d %H:%M'))" | tee -a "$LOG"
run pwd
run "ls -la"
run "mkdir -p scratch"
run "cd scratch && pwd"
run "touch scratch/empty.txt"
run "echo 'hello workspace' > scratch/hello.txt"
run "cat scratch/hello.txt"
run "cp scratch/hello.txt scratch/hello-copy.txt"
run "mv scratch/hello-copy.txt scratch/renamed.txt"
run "ls -la scratch"
run "rm scratch/empty.txt"
run "ls -la scratch"

# ---------- 권한 실습 ----------
LOG=logs/02-permission.txt
: > "$LOG"
echo "### 권한 실습 로그 ($(date '+%Y-%m-%d %H:%M'))" | tee -a "$LOG"
run "mkdir -p scratch/perm-dir && echo 'echo run ok' > scratch/perm.sh"
echo "## [변경 전]" | tee -a "$LOG"
run "ls -l scratch/perm.sh"
run "ls -ld scratch/perm-dir"
run "./scratch/perm.sh || echo '→ 실행 실패: 실행 권한(x)이 없음'"
echo "## [파일: chmod 755 → rwxr-xr-x]" | tee -a "$LOG"
run "chmod 755 scratch/perm.sh"
run "ls -l scratch/perm.sh"
run "./scratch/perm.sh"
echo "## [파일: chmod 644 → rw-r--r--, 다시 실행 불가]" | tee -a "$LOG"
run "chmod 644 scratch/perm.sh"
run "ls -l scratch/perm.sh"
run "./scratch/perm.sh || echo '→ 다시 실행 실패: 644 는 rw-r--r-- (x 없음)'"
echo "## [디렉토리: chmod 700 → 소유자만 접근]" | tee -a "$LOG"
run "chmod 700 scratch/perm-dir"
run "ls -ld scratch/perm-dir"
run "chmod 755 scratch/perm-dir"
run "ls -ld scratch/perm-dir"

echo "완료 → logs/01-terminal.txt, logs/02-permission.txt"
