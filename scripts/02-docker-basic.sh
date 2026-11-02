#!/usr/bin/env bash
# 요구사항 4·5·6: Docker 설치 점검, 기본 운영 명령, 컨테이너 실행 실습
# 실행: bash scripts/02-docker-basic.sh   (Docker Desktop 켜져 있어야 함)
# 결과: logs/03-docker-check.txt, logs/04-docker-ops.txt, logs/05-container-practice.txt
set -u
cd "$(dirname "$0")/.." || exit 1
mkdir -p logs

run() { echo "\$ $*" | tee -a "$LOG"; eval "$@" 2>&1 | tee -a "$LOG"; echo | tee -a "$LOG"; }

# ---------- 설치 점검 ----------
LOG=logs/03-docker-check.txt; : > "$LOG"
echo "### Docker 설치 점검 ($(date '+%Y-%m-%d %H:%M'))" | tee -a "$LOG"
run "docker --version"
run "docker compose version"
run "docker info --format 'Server Version: {{.ServerVersion}} / OS: {{.OperatingSystem}} / CPUs: {{.NCPU}} / Mem: {{.MemTotal}}'"
run "docker info | head -30"

# ---------- 컨테이너 실행 실습 ----------
LOG=logs/05-container-practice.txt; : > "$LOG"
echo "### 컨테이너 실행 실습 ($(date '+%Y-%m-%d %H:%M'))" | tee -a "$LOG"
echo "## hello-world" | tee -a "$LOG"
run "docker run --name hello hello-world"
echo "## ubuntu 컨테이너 내부 명령 (docker run → 1회성 실행 후 종료)" | tee -a "$LOG"
run "docker run --name ubu-once ubuntu bash -c 'echo \"[container] hostname=\$(hostname)\"; cat /etc/os-release | head -2; ls /'"
echo "## ubuntu 컨테이너 유지 (-d + sleep) 후 exec 로 진입" | tee -a "$LOG"
run "docker run -d --name ubu-keep ubuntu sleep 600"
run "docker exec ubu-keep bash -c 'echo \"[exec] whoami=\$(whoami)\"; echo hello-from-exec > /tmp/note.txt; cat /tmp/note.txt'"
run "docker exec ubu-keep ls -l /tmp"
echo "## 종료/유지 차이 관찰: ubu-once 는 Exited, ubu-keep 은 Up" | tee -a "$LOG"
run "docker ps -a --filter name=ubu- --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Command}}'"

# ---------- 기본 운영 명령 ----------
LOG=logs/04-docker-ops.txt; : > "$LOG"
echo "### Docker 기본 운영 명령 ($(date '+%Y-%m-%d %H:%M'))" | tee -a "$LOG"
run "docker pull alpine:3.20"
run "docker images"
run "docker ps"
run "docker ps -a"
run "docker logs hello"
run "docker stats --no-stream"
run "docker stop ubu-keep"
run "docker ps -a --filter name=ubu-keep --format 'table {{.Names}}\t{{.Status}}'"
run "docker start ubu-keep"
run "docker ps --filter name=ubu-keep --format 'table {{.Names}}\t{{.Status}}'"
run "docker rm -f hello ubu-once ubu-keep"
run "docker ps -a"

echo "완료 → logs/03-docker-check.txt, logs/04-docker-ops.txt, logs/05-container-practice.txt"
