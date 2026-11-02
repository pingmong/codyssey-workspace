#!/usr/bin/env bash
# 요구사항 7·8·9: 커스텀 이미지 빌드, 포트 매핑 접속, 바인드 마운트, 볼륨 영속성
# 실행: bash scripts/03-docker-image.sh
# 결과: logs/06-build-run.txt, logs/07-port-mapping.txt, logs/08-bind-mount.txt, logs/09-volume.txt
set -u
cd "$(dirname "$0")/.." || exit 1
mkdir -p logs

run() { echo "\$ $*" | tee -a "$LOG"; eval "$@" 2>&1 | tee -a "$LOG"; echo | tee -a "$LOG"; }

# ---------- 빌드 & 실행 ----------
LOG=logs/06-build-run.txt; : > "$LOG"
echo "### 커스텀 이미지 빌드/실행 ($(date '+%Y-%m-%d %H:%M'))" | tee -a "$LOG"
run "cat app/Dockerfile"
run "docker build -t codyssey-web:v1 ./app"
run "docker images codyssey-web"
run "docker image history codyssey-web:v1 | head -8"
run "docker run -d --name web -p 8080:80 codyssey-web:v1"
run "sleep 3; docker ps --filter name=web --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'"
run "docker logs web | tail -5"

# ---------- 포트 매핑 ----------
LOG=logs/07-port-mapping.txt; : > "$LOG"
echo "### 포트 매핑 접속 증거 ($(date '+%Y-%m-%d %H:%M'))" | tee -a "$LOG"
run "docker port web"
run "curl -s -o /dev/null -w 'HTTP %{http_code}\n' http://localhost:8080"
run "curl -s http://localhost:8080 | head -20"
echo "(브라우저에서 http://localhost:8080 열어 스크린샷 → screenshots/port-mapping.png)" | tee -a "$LOG"
run "docker rm -f web"

# ---------- 바인드 마운트 ----------
LOG=logs/08-bind-mount.txt; : > "$LOG"
echo "### 바인드 마운트 반영 ($(date '+%Y-%m-%d %H:%M'))" | tee -a "$LOG"
echo "## 호스트의 app/ 폴더를 컨테이너의 /usr/share/nginx/html 에 연결" | tee -a "$LOG"
run "docker run -d --name web-bind -p 8080:80 -v \"\$(pwd)/app:/usr/share/nginx/html:ro\" nginx:alpine"
run "sleep 2; echo '## [변경 전] 호스트 파일의 badge:'; grep -o 'class=\"badge\">[^<]*' app/index.html"
run "curl -s http://localhost:8080 | grep -o 'class=\"badge\">[^<]*'"
run "sed -i '' 's/class=\"badge\">v1/class=\"badge\">v2-bind-mount/' app/index.html"
run "echo '## [변경 후] 호스트 파일 수정 → 컨테이너 재시작 없이 즉시 반영'"
run "curl -s http://localhost:8080 | grep -o 'class=\"badge\">[^<]*'"
run "sed -i '' 's/class=\"badge\">v2-bind-mount/class=\"badge\">v1/' app/index.html"
run "docker rm -f web-bind"

# ---------- 볼륨 영속성 ----------
LOG=logs/09-volume.txt; : > "$LOG"
echo "### Docker 볼륨 영속성 검증 ($(date '+%Y-%m-%d %H:%M'))" | tee -a "$LOG"
run "docker volume create codyssey-data"
run "docker volume ls"
run "docker volume inspect codyssey-data"
echo "## [1] 컨테이너 A 가 볼륨에 데이터 기록" | tee -a "$LOG"
run "docker run --rm --name writer -v codyssey-data:/data alpine sh -c 'echo \"written at \$(date)\" >> /data/persist.txt; cat /data/persist.txt'"
echo "## [2] 컨테이너 A 삭제됨 (--rm) → 볼륨만 남음" | tee -a "$LOG"
run "docker ps -a --filter name=writer"
echo "## [3] 새 컨테이너 B 가 같은 볼륨을 붙여서 데이터 확인" | tee -a "$LOG"
run "docker run --rm --name reader -v codyssey-data:/data alpine cat /data/persist.txt"
echo "## [비교] 볼륨 없이 쓴 데이터는 컨테이너와 함께 사라짐" | tee -a "$LOG"
run "docker run --rm alpine sh -c 'echo gone > /data-no-vol.txt; cat /data-no-vol.txt'"
run "docker run --rm alpine sh -c 'cat /data-no-vol.txt || echo \"(파일 없음: 컨테이너 삭제와 함께 사라짐)\"'"

echo "완료 → logs/06~09"
