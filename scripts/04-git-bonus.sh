#!/usr/bin/env bash
# 요구사항 10 + 보너스 1~5: Git 설정 기록, Compose 단일/멀티, 환경 변수, SSH
# 실행: bash scripts/04-git-bonus.sh
# 결과: logs/10-git-config.txt, logs/11-compose-single.txt, logs/12-compose-multi.txt, logs/13-env-var.txt, logs/14-ssh.txt
set -u
cd "$(dirname "$0")/.." || exit 1
mkdir -p logs

run() { echo "\$ $*" | tee -a "$LOG"; eval "$@" 2>&1 | tee -a "$LOG"; echo | tee -a "$LOG"; }

# ---------- Git 설정 ----------
LOG=logs/10-git-config.txt; : > "$LOG"
echo "### Git 설정 ($(date '+%Y-%m-%d %H:%M'))" | tee -a "$LOG"
run "git --version"
run "git config --list --show-origin | grep -E 'user\.|init\.|core\.editor|credential' | sed -E 's/(token|password)=.*/\1=****/'"
run "git remote -v"
run "git branch --show-current"
run "git log --oneline | head -10"

# ---------- 보너스 1: Compose 단일 ----------
LOG=logs/11-compose-single.txt; : > "$LOG"
echo "### Compose 단일 서비스 ($(date '+%Y-%m-%d %H:%M'))" | tee -a "$LOG"
run "cat compose-single/docker-compose.yml"
run "cd compose-single && docker compose up -d --build"
run "cd compose-single && docker compose ps"
run "curl -s -o /dev/null -w 'HTTP %{http_code} on :8080\n' http://localhost:8080"
run "cd compose-single && docker compose logs --tail 5"
run "cd compose-single && docker compose down"
run "cd compose-single && docker compose ps"

# ---------- 보너스 4: 환경 변수로 포트 변경 ----------
LOG=logs/13-env-var.txt; : > "$LOG"
echo "### 환경 변수 활용 ($(date '+%Y-%m-%d %H:%M'))" | tee -a "$LOG"
run "cat compose-single/.env.example"
run "cp compose-single/.env.example compose-single/.env"
run "cd compose-single && docker compose config | grep -A2 ports"
run "cd compose-single && docker compose up -d"
run "curl -s -o /dev/null -w 'HTTP %{http_code} on :9090 (env WEB_PORT)\n' http://localhost:9090"
run "cd compose-single && docker compose down"
run "rm compose-single/.env"
echo "## Dockerfile 쪽 환경 변수: docker run -e 로 주입" | tee -a "$LOG"
run "docker run --rm -e APP_MODE=production alpine sh -c 'echo APP_MODE=\$APP_MODE'"

# ---------- 보너스 2·3: Compose 멀티 ----------
LOG=logs/12-compose-multi.txt; : > "$LOG"
echo "### Compose 멀티 컨테이너 ($(date '+%Y-%m-%d %H:%M'))" | tee -a "$LOG"
run "cat compose-multi/docker-compose.yml"
run "cd compose-multi && docker compose up -d --build"
run "cd compose-multi && docker compose ps"
echo "## 컨테이너 간 통신: web 컨테이너에서 서비스 이름 'cache' 로 redis 에 접속" | tee -a "$LOG"
run "docker exec multi-web sh -c 'getent hosts cache'"
run "docker exec multi-web sh -c 'nc -zv cache 6379'"
run "docker exec multi-cache redis-cli ping"
run "docker network ls | grep compose-multi"
run "cd compose-multi && docker compose logs --tail 3"
run "cd compose-multi && docker compose down"
run "docker ps -a"

# ---------- 보너스 5: SSH ----------
LOG=logs/14-ssh.txt; : > "$LOG"
echo "### GitHub SSH ($(date '+%Y-%m-%d %H:%M'))" | tee -a "$LOG"
run "ls ~/.ssh/*.pub 2>/dev/null || echo '(공개키 없음 → ssh-keygen -t ed25519 -C \"email\" 로 생성)'"
run "ssh -T git@github.com 2>&1 | head -2"
run "git remote -v"

echo "완료 → logs/10~14"
