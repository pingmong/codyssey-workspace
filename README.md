# AI/SW 개발 워크스페이스 구축

> Codyssey 입학연수 Pre-course · Dev Setup 미션 수행 기록

## 1. 프로젝트 개요

터미널·Docker·Git 세 가지 도구를 직접 세팅하고, "내 컴퓨터에서만 돌아가는" 환경이 아니라 **누가 실행해도 같은 결과가 재현되는** 개발 워크스테이션을 만드는 것이 목표입니다.

이 저장소에서 한 일:

- 터미널로 작업 디렉토리와 파일 권한을 정리하고
- Docker를 설치·점검한 뒤 컨테이너를 실행/관리하고
- NGINX 베이스 이미지 위에 정적 페이지를 얹은 **커스텀 이미지**를 Dockerfile로 만들고
- 포트 매핑 / 바인드 마운트 / 볼륨으로 "접속", "변경 반영", "데이터 영속성"을 검증하고
- Git/GitHub/VSCode를 연동했습니다.
- (보너스) Docker Compose 단일·멀티 컨테이너, 환경 변수, SSH 키까지 진행했습니다.

모든 실습은 `scripts/` 의 셸 스크립트로 **순서대로 실행하고 결과를 `logs/` 에 자동 기록**했습니다. 아래 본문은 그 로그의 요약이며, 전체 출력은 각 로그 파일에서 확인할 수 있습니다.

## 2. 실행 환경

| 항목 | 값 |
|---|---|
| OS | macOS 26.7.1 (Apple Silicon, arm64) |
| 셸 / 터미널 | zsh + Bash 스크립트 |
| Docker | Docker version 29.8.1, build 4a63305 (Docker Desktop) |
| Docker Compose | v5.5.1 |
| Git | git version 2.50.1 (Apple Git-155) + gh CLI 2.103.3 |
| 에디터 | VSCode |

## 3. 저장소 구조

```
.
├── app/                    # 커스텀 이미지 소스 (Dockerfile + index.html)
├── compose-single/         # 보너스: 단일 서비스 Compose (+ .env.example)
├── compose-multi/          # 보너스: 웹 + Redis 멀티 컨테이너 Compose
├── scripts/                # 실습 명령을 순서대로 실행하고 logs/ 에 기록하는 스크립트
│   ├── 01-terminal.sh      #   터미널 조작 + 권한
│   ├── 02-docker-basic.sh  #   설치 점검 + 운영 명령 + 컨테이너 실행
│   ├── 03-docker-image.sh  #   빌드 + 포트 매핑 + 바인드 마운트 + 볼륨
│   └── 04-git-bonus.sh     #   Git 설정 + Compose + 환경 변수 + SSH
├── logs/                   # 실제 실행 로그 (증거). trouble-* 는 실패 당시 로그
├── screenshots/            # 브라우저 접속, VSCode-GitHub 연동 캡처
└── README.md
```

## 4. 수행 항목 체크리스트

| # | 항목 | 상태 | 증거 |
|---|---|---|---|
| 1 | 터미널 조작 (pwd, ls -la, mkdir, cp, mv, rm, touch, cat) | ✅ | `logs/01-terminal.txt` |
| 2 | 권한 확인/변경 (파일 1 + 디렉토리 1, 전/후 비교) | ✅ | `logs/02-permission.txt` |
| 3 | Docker 설치 점검 (`docker --version`, `docker info`) | ✅ | `logs/03-docker-check.txt` |
| 4 | Docker 기본 운영 (images, ps, logs, stats, stop/start/rm) | ✅ | `logs/04-docker-ops.txt` |
| 5 | hello-world / ubuntu 실행, 종료 vs 유지(exec) 관찰 | ✅ | `logs/05-container-practice.txt` |
| 6 | Dockerfile 커스텀 이미지 빌드·실행 | ✅ | `logs/06-build-run.txt` |
| 7 | 포트 매핑 접속 증거 | ✅ | `logs/07-port-mapping.txt`, `screenshots/port-mapping.png` |
| 8 | 바인드 마운트 변경 반영 (전/후) | ✅ | `logs/08-bind-mount.txt` |
| 9 | Docker 볼륨 영속성 (컨테이너 삭제 전/후) | ✅ | `logs/09-volume.txt` |
| 10 | Git 설정 + GitHub/VSCode 연동 | ✅ | `logs/10-git-config.txt`, `screenshots/vscode-github.png` |
| 11 | 보안: 토큰/비밀번호 마스킹 | ✅ | 본 문서 전체, `.gitignore` |
| B1 | Compose 단일 서비스 | ✅ | `logs/11-compose-single.txt` |
| B2 | Compose 멀티 컨테이너 + 네트워크 통신 | ✅ | `logs/12-compose-multi.txt` |
| B3 | Compose 운영 명령 (up/down/ps/logs) | ✅ | `logs/11`, `logs/12` |
| B4 | 환경 변수로 포트 변경 | ✅ | `logs/13-env-var.txt` |
| B5 | GitHub SSH 키 | ✅ | `logs/14-ssh.txt` |

## 5. 수행 내용

### 5-1. 터미널 조작

`scripts/01-terminal.sh` → `logs/01-terminal.txt`

```bash
$ pwd
/Users/gimnayeon/Developments/codyssey-workspace

$ ls -la                       # 숨김 파일(.git, .gitignore) 포함 목록
drwxr-xr-x@ 12 gimnayeon  staff   384 11월  2 14:29 .git
-rw-------@  1 gimnayeon  staff   126 11월  2 14:15 .gitignore
...

$ mkdir -p scratch             # 생성
$ touch scratch/empty.txt      # 빈 파일 생성
$ echo 'hello workspace' > scratch/hello.txt
$ cat scratch/hello.txt        # 내용 확인
hello workspace
$ cp scratch/hello.txt scratch/hello-copy.txt     # 복사
$ mv scratch/hello-copy.txt scratch/renamed.txt   # 이름 변경
$ rm scratch/empty.txt                            # 삭제
$ ls -la scratch
-rw-r--r--@  1 gimnayeon  staff   16 11월  2 14:29 hello.txt
-rw-r--r--@  1 gimnayeon  staff   16 11월  2 14:29 renamed.txt
```

절대 경로(`/Users/gimnayeon/.../codyssey-workspace`)는 루트부터 시작하는 전체 주소이고, 상대 경로(`scratch/hello.txt`)는 "지금 있는 위치(pwd)" 기준입니다. 같은 `scratch/hello.txt`라도 어디서 실행하느냐에 따라 다른 파일을 가리킬 수 있습니다.

### 5-2. 권한 실습

`logs/02-permission.txt` — 파일 1개(`perm.sh`), 디렉토리 1개(`perm-dir`)

| 단계 | 명령 | 결과 (`ls -l`) | 실행 |
|---|---|---|---|
| 변경 전 | — | `-rw-r--r--` (644) | `Permission denied` |
| 파일 755 | `chmod 755 scratch/perm.sh` | `-rwxr-xr-x` | `run ok` |
| 파일 644 | `chmod 644 scratch/perm.sh` | `-rw-r--r--` | 다시 `Permission denied` |
| 디렉토리 700 | `chmod 700 scratch/perm-dir` | `drwx------` | 소유자만 접근 |
| 디렉토리 755 | `chmod 755 scratch/perm-dir` | `drwxr-xr-x` | 모두 읽기/진입 |

```bash
$ ./scratch/perm.sh
scripts/01-terminal.sh: line 13: ./scratch/perm.sh: Permission denied
$ chmod 755 scratch/perm.sh && ./scratch/perm.sh
run ok
```

`rwx` 는 각각 read(4) / write(2) / execute(1)이고, 세 자리는 **소유자 / 그룹 / 그 외** 순서입니다. `755` = `rwx r-x r-x`, `644` = `rw- r-- r--`. 스크립트는 `x`가 없으면 내용이 맞아도 실행할 수 없습니다. (이 권한 개념은 뒤의 트러블슈팅 7-2에서 실제 장애 원인으로 다시 등장합니다.)

### 5-3. Docker 설치 및 기본 점검

`logs/03-docker-check.txt`

```bash
$ docker --version
Docker version 29.8.1, build 4a63305

$ docker compose version
Docker Compose version v5.5.1

$ docker info --format '...'
Server Version: 29.8.1 / OS: Docker Desktop / CPUs: 8 / Mem: 8319770624
```

`docker --version`은 CLI(클라이언트)만 확인하고, `docker info`가 실제 데몬(서버)이 떠 있는지 확인합니다. Docker Desktop이 꺼져 있으면 `--version`은 되지만 `info`에서 "Cannot connect to the Docker daemon" 이 납니다.

### 5-4. Docker 기본 운영 명령

`logs/04-docker-ops.txt`

```bash
$ docker pull alpine:3.20          # 이미지 다운로드
$ docker images                    # 이미지 목록
IMAGE               ID             DISK USAGE   CONTENT SIZE
alpine:3.20         d9e853e87e55       13.7MB         4.17MB
hello-world:latest  c567b231f656       22.6kB         10.3kB
ubuntu:latest       6a06111c3b0a        181MB         44.9MB

$ docker ps                        # 실행 중인 컨테이너만
$ docker ps -a                     # 종료된 것 포함
CONTAINER ID   IMAGE         STATUS                     NAMES
b61a55cf427d   ubuntu        Up 3 seconds               ubu-keep
fef726abf879   ubuntu        Exited (0) 3 seconds ago   ubu-once
09545e79392a   hello-world   Exited (0) 3 seconds ago   hello

$ docker logs hello                # 종료된 컨테이너의 출력도 볼 수 있음
Hello from Docker! ...

$ docker stats --no-stream         # 리소스 사용량
CONTAINER ID   NAME       CPU %     MEM USAGE / LIMIT     MEM %
b61a55cf427d   ubu-keep   0.00%     3.66MiB / 7.748GiB    0.05%

$ docker stop ubu-keep             # → Exited (137)
$ docker start ubu-keep            # → Up
$ docker rm -f hello ubu-once ubu-keep
```

### 5-5. 컨테이너 실행 실습 (hello-world, ubuntu, 종료 vs 유지)

`logs/05-container-practice.txt`

```bash
$ docker run --name hello hello-world
Hello from Docker!
This message shows that your installation appears to be working correctly.

# ubuntu: 명령 하나 실행하고 바로 종료
$ docker run --name ubu-once ubuntu bash -c 'echo "[container] hostname=$(hostname)"; cat /etc/os-release | head -2; ls /'
[container] hostname=fef726abf879
PRETTY_NAME="Ubuntu 26.04.1 LTS"
bin boot dev etc home lib ...

# ubuntu: 백그라운드로 살려두고(-d) exec 로 들어가서 작업
$ docker run -d --name ubu-keep ubuntu sleep 600
$ docker exec ubu-keep bash -c 'echo "[exec] whoami=$(whoami)"; echo hello-from-exec > /tmp/note.txt; cat /tmp/note.txt'
[exec] whoami=root
hello-from-exec

$ docker ps -a --filter name=ubu-
NAMES      IMAGE     STATUS                              COMMAND
ubu-keep   ubuntu    Up Less than a second               "sleep 600"
ubu-once   ubuntu    Exited (0) Less than a second ago   "bash -c 'echo ..."
```

**관찰:** 컨테이너는 "메인 프로세스가 끝나면 함께 종료"됩니다. `ubu-once`는 `bash -c '...'`가 끝나자 Exited, `ubu-keep`은 `sleep 600`이 살아 있으니 Up. 살아 있는 컨테이너에 `docker exec`로 **추가 프로세스**를 띄워 들어가는 것과, `docker attach`로 **메인 프로세스에 붙는** 것은 다릅니다. attach에서 `exit`하면 메인이 끝나 컨테이너가 죽지만, exec에서 `exit`하면 컨테이너는 그대로입니다.

### 5-6. 커스텀 이미지 제작 (Dockerfile)

`app/Dockerfile`, `logs/06-build-run.txt`

**선택한 베이스:** `nginx:alpine` (방식 A — 웹 서버 베이스 이미지 + 정적 콘텐츠 교체)

```dockerfile
FROM nginx:alpine
COPY --chmod=644 index.html /usr/share/nginx/html/index.html
EXPOSE 80
HEALTHCHECK --interval=10s --timeout=3s CMD wget -qO- http://localhost/ > /dev/null || exit 1
```

**커스텀 포인트:**

| # | 변경 | 목적 |
|---|---|---|
| 1 | `COPY --chmod=644 index.html ...` | NGINX 기본 환영 페이지를 우리 페이지로 교체. `--chmod=644`는 호스트 파일 권한과 무관하게 nginx 워커(비root)가 읽을 수 있도록 고정 (→ 트러블슈팅 7-2) |
| 2 | `EXPOSE 80` | 컨테이너가 사용하는 포트를 문서화. 실제 개방은 `-p`가 담당 |
| 3 | `HEALTHCHECK` | 컨테이너는 살아 있어도 서비스가 죽은 상태를 Docker가 감지 (`docker ps`에 healthy/unhealthy 표시) |

```bash
$ docker build -t codyssey-web:v1 ./app
#5 [1/2] FROM docker.io/library/nginx:alpine@sha256:785835ea...   CACHED
#6 [2/2] COPY --chmod=644 index.html /usr/share/nginx/html/index.html   DONE 0.0s
#7 naming to docker.io/library/codyssey-web:v1 done

$ docker images codyssey-web
IMAGE             ID             DISK USAGE   CONTENT SIZE
codyssey-web:v1   ba3232b96167       93.2MB         26.3MB

$ docker image history codyssey-web:v1 | head -4      # 레이어 = Dockerfile 한 줄
ba3232b96167   HEALTHCHECK {Test:[CMD-SHELL wget -qO- http:…   0B
<missing>      EXPOSE [80/tcp]                                  0B
<missing>      COPY --chmod=644 index.html /usr/share/nginx…   24.6kB

$ docker run -d --name web -p 8080:80 codyssey-web:v1
$ docker ps --filter name=web
NAMES   IMAGE             STATUS                          PORTS
web     codyssey-web:v1   Up 3 seconds (health: starting) 0.0.0.0:8080->80/tcp
```

### 5-7. 포트 매핑 접속 증거

`logs/07-port-mapping.txt`, `screenshots/port-mapping.png`

```bash
$ docker port web
80/tcp -> 0.0.0.0:8080

$ curl -s -o /dev/null -w 'HTTP %{http_code}\n' http://localhost:8080
HTTP 200

$ curl -s http://localhost:8080 | head -20
<!DOCTYPE html>
<html lang="ko">
  <title>Codyssey Workspace</title>
  ...
  <h1>AI/SW 개발 워크스페이스 구축</h1>
```

![port mapping](screenshots/port-mapping.png)

컨테이너는 자기만의 네트워크 공간을 가지므로 안에서 80번을 열어도 호스트에서는 보이지 않습니다. `-p 8080:80`은 "호스트 8080으로 들어온 요청을 컨테이너 80으로 넘겨라"는 연결이고, 그래서 브라우저 주소는 `localhost:8080`입니다. 호스트 포트만 바꾸면(`-p 9090:80`) 같은 이미지를 여러 개 동시에 띄울 수 있습니다.

### 5-8. 바인드 마운트 vs 볼륨

**바인드 마운트 — 호스트 파일 변경이 즉시 반영** (`logs/08-bind-mount.txt`)

```bash
$ docker run -d --name web-bind -p 8080:80 -v "$(pwd)/app:/usr/share/nginx/html:ro" nginx:alpine

## [변경 전]
$ curl -s http://localhost:8080 | grep -o 'class="badge">[^<]*'
class="badge">v1

$ sed -i '' 's/class="badge">v1/class="badge">v2-bind-mount/' app/index.html   # 호스트에서 수정

## [변경 후] 컨테이너 재시작 없이 즉시 반영
$ curl -s http://localhost:8080 | grep -o 'class="badge">[^<]*'
class="badge">v2-bind-mount
```

**Docker 볼륨 — 컨테이너를 지워도 데이터 유지** (`logs/09-volume.txt`)

```bash
$ docker volume create codyssey-data
$ docker volume inspect codyssey-data
"Mountpoint": "/var/lib/docker/volumes/codyssey-data/_data"

## [1] 컨테이너 A 가 볼륨에 기록 (--rm: 끝나면 자동 삭제)
$ docker run --rm --name writer -v codyssey-data:/data alpine sh -c 'echo "written at $(date)" >> /data/persist.txt; cat /data/persist.txt'
written at Mon Nov  2 05:30:56 UTC 2026
written at Mon Nov  2 05:33:00 UTC 2026

## [2] 컨테이너 A 는 이미 삭제됨
$ docker ps -a --filter name=writer
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES   (없음)

## [3] 새 컨테이너 B 가 같은 볼륨을 붙여 읽기 → 데이터 그대로
$ docker run --rm --name reader -v codyssey-data:/data alpine cat /data/persist.txt
written at Mon Nov  2 05:30:56 UTC 2026
written at Mon Nov  2 05:33:00 UTC 2026

## [비교] 볼륨 없이 쓴 파일은 컨테이너와 함께 사라짐
$ docker run --rm alpine sh -c 'echo gone > /data-no-vol.txt; cat /data-no-vol.txt'
gone
$ docker run --rm alpine sh -c 'cat /data-no-vol.txt'
cat: can't open '/data-no-vol.txt': No such file or directory
```

(스크립트를 두 번 실행해서 `persist.txt`에 줄이 두 개 쌓였는데, 이것 자체가 "실행을 반복해도 볼륨 데이터는 누적·유지된다"는 증거입니다.)

| | 바인드 마운트 `-v /host/path:/ctr/path` | 볼륨 `-v name:/ctr/path` |
|---|---|---|
| 데이터 위치 | 호스트의 내가 정한 폴더 | Docker가 관리하는 영역 |
| 용도 | 개발 중 소스 즉시 반영 | DB 데이터 등 영속 저장 |
| 컨테이너 삭제 시 | 호스트 파일은 그대로 | 볼륨은 그대로 (`docker volume rm` 전까지) |

### 5-9. Git 설정 및 GitHub/VSCode 연동

`logs/10-git-config.txt`, `screenshots/vscode-github.png`

```bash
$ git --version
git version 2.50.1 (Apple Git-155)

$ git config --list --show-origin | grep -E 'user\.|init\.|core\.editor|credential'
file:/Library/.../git-core/gitconfig   credential.helper=osxkeychain
file:/Library/.../git-core/gitconfig   init.defaultbranch=main
file:/Users/gimnayeon/.gitconfig       user.name=pingmong
file:/Users/gimnayeon/.gitconfig       user.email=****@****            # 마스킹
file:/Users/gimnayeon/.gitconfig       core.editor=code --wait
file:/Users/gimnayeon/.gitconfig       init.defaultbranch=main
file:/Users/gimnayeon/.gitconfig       credential.https://github.com.helper=!/opt/homebrew/bin/gh auth git-credential

$ git remote -v
origin  https://github.com/pingmong/codyssey-workspace.git (fetch)
origin  https://github.com/pingmong/codyssey-workspace.git (push)

$ git branch --show-current
main
```

- 사용자 정보(`user.name`, `user.email`)와 기본 브랜치(`init.defaultbranch=main`)가 설정되어 있고, GitHub 인증은 트러블슈팅 7-1을 거쳐 `gh auth git-credential` 헬퍼로 연결됨.
- VSCode: 왼쪽 아래 계정 아이콘으로 GitHub 로그인 후, 이 저장소를 열어 Source Control 패널에서 커밋/푸시 가능 상태 확인.

![vscode github](screenshots/vscode-github.png)

## 6. 보너스 과제

### B1. Docker Compose 단일 서비스

`compose-single/docker-compose.yml`, `logs/11-compose-single.txt`

```yaml
services:
  web:
    build: ../app                  # ../app/Dockerfile 로 이미지 빌드
    image: codyssey-web:compose
    container_name: compose-web
    ports:
      - "${WEB_PORT:-8080}:80"     # 환경 변수로 호스트 포트 변경 (기본 8080)
```

```bash
$ docker compose up -d --build
 Image codyssey-web:compose Built
 Network compose-single_default Created
 Container compose-web Started

$ docker compose ps
NAME          IMAGE                  SERVICE   STATUS                     PORTS
compose-web   codyssey-web:compose   web       Up (health: starting)      0.0.0.0:8080->80/tcp

$ curl -s -o /dev/null -w 'HTTP %{http_code}\n' http://localhost:8080
HTTP 200 on :8080

$ docker compose logs --tail 5
compose-web  | 192.168.65.1 - - [02/Nov/2026:05:39:48 +0000] "GET / HTTP/1.1" 200 881 "-" "curl/8.7.1"

$ docker compose down
 Container compose-web Removed
 Network compose-single_default Removed
```

**배움 포인트:** 5-6에서 쳤던 `docker build -t ... ./app` + `docker run -d --name web -p 8080:80 ...` 두 명령이 yml 파일 8줄로 바뀌고, 실행은 `docker compose up` 한 줄이 됐다. 명령을 "기억"하는 대신 파일로 "문서화"하니 저장소를 clone한 누구라도 같은 방식으로 띄울 수 있다. `down`이 컨테이너와 네트워크까지 깔끔히 치우는 것도 `docker rm` + `docker network rm`을 손으로 하는 것보다 안전하다.

### B2·B3. 멀티 컨테이너 + 운영 명령

`compose-multi/docker-compose.yml`, `logs/12-compose-multi.txt`

```yaml
services:
  web:
    build: ../app
    container_name: multi-web
    ports: ["8081:80"]
    depends_on: [cache]
  cache:
    image: redis:7-alpine
    container_name: multi-cache      # 호스트 포트 없음 → 컨테이너끼리만 통신
```

```bash
$ docker compose up -d --build
 Image redis:7-alpine Pulled
 Container multi-cache Started
 Container multi-web Started

$ docker compose ps
NAME          IMAGE                SERVICE   STATUS                  PORTS
multi-cache   redis:7-alpine       cache     Up                      6379/tcp
multi-web     codyssey-web:multi   web       Up (health: starting)   0.0.0.0:8081->80/tcp

## 컨테이너 간 통신: web 에서 서비스 이름 'cache' 로 redis 찾기
$ docker exec multi-web sh -c 'getent hosts cache'
172.21.0.2        cache  cache
$ docker exec multi-web sh -c 'nc -zv cache 6379'
cache (172.21.0.2:6379) open
$ docker exec multi-cache redis-cli ping
PONG

$ docker network ls | grep compose-multi
cefad326255b   compose-multi_default   bridge   local

$ docker compose logs --tail 3
multi-web    | ... start worker process 37
multi-cache  | ... Ready to accept connections tcp

$ docker compose down
```

**배움 포인트 (네트워크/서비스 디스커버리):** Compose가 `compose-multi_default` 네트워크를 자동으로 만들고 두 컨테이너를 넣어 준다. 그 안에서는 **서비스 이름이 곧 호스트 이름**이라, web 컨테이너는 IP를 몰라도 `cache:6379`로 Redis에 붙는다. `cache`는 호스트에 포트를 열지 않았으므로 내 Mac에서는 접근 불가, 컨테이너끼리만 통신 — "외부에 노출할 것과 내부에 숨길 것"을 yml에서 결정한다.

**운영 루틴 (B3):** `up -d` → `ps`(상태) → `logs --tail`(이상 확인) → `down`(정리). 서비스가 몇 개든 같은 네 명령이다.

### B4. 환경 변수 활용

`compose-single/.env.example`, `logs/13-env-var.txt`

```bash
$ cat compose-single/.env.example
WEB_PORT=9090

$ cp compose-single/.env.example compose-single/.env     # Compose 가 .env 를 자동으로 읽음
$ docker compose up -d
$ curl -s -o /dev/null -w 'HTTP %{http_code}\n' http://localhost:9090
HTTP 200 on :9090 (env WEB_PORT)
$ docker compose down && rm compose-single/.env

## Dockerfile/run 쪽: -e 로 컨테이너 안에 주입
$ docker run --rm -e APP_MODE=production alpine sh -c 'echo APP_MODE=$APP_MODE'
APP_MODE=production
```

**배움 포인트 (설정과 코드의 분리):** yml은 한 글자도 안 바꾸고 `.env` 파일만으로 포트가 8080 → 9090으로 바뀌었다. 포트, 비밀번호, 모드 같은 "환경마다 다른 값"은 코드/설정 파일에 박지 않고 환경 변수로 바깥에서 넣는다. 그래서 `.env`는 `.gitignore`로 제외하고, 어떤 키가 필요한지만 보여 주는 `.env.example`을 커밋한다.

### B5. GitHub SSH 키

`logs/14-ssh.txt`

```bash
$ ls ~/.ssh/*.pub
/Users/gimnayeon/.ssh/id_ed25519.pub
/Users/gimnayeon/.ssh/id_rsa.pub

$ ssh -T git@github.com
Hi pingmong! You've successfully authenticated, but GitHub does not provide shell access.

$ git remote set-url origin git@github.com:pingmong/codyssey-workspace.git   # HTTPS → SSH 전환
$ git remote -v
origin  git@github.com:pingmong/codyssey-workspace.git (fetch)
origin  git@github.com:pingmong/codyssey-workspace.git (push)
$ git push                                                                    # 비밀번호/토큰 없이 푸시
```

기존 ed25519 키가 이미 GitHub에 등록되어 있어 새로 만들지 않았다. (`ssh-keygen`을 다시 실행하면 "already exists, Overwrite?"가 뜨는데, 덮어쓰면 그 키를 쓰던 다른 서비스 접속이 끊기므로 `n`.)

**배움 포인트 (인증 방식 차이):** HTTPS는 매번 토큰(또는 헬퍼에 저장된 토큰)으로 인증하고, SSH는 내 컴퓨터의 **개인키**와 GitHub에 등록한 **공개키** 쌍으로 인증한다. 개인키(`id_ed25519`)는 절대 복사·공유·커밋하지 않고, 공개키(`.pub`)만 등록한다. 7-1처럼 HTTPS 헬퍼 설정이 꼬여도 SSH는 영향을 받지 않는다.

## 7. 트러블슈팅

### 7-1. `git push` 시 `git: 'credential-winstore' is not a git command` → 인증 실패

- **문제:** 첫 `git push -u origin main`에서 위 메시지가 뜨고 Username/Password를 직접 물어본 뒤, 입력해도 `remote: Invalid username or token. Password authentication is not supported for Git operations.` 로 실패.
- **원인 가설:** `credential-winstore`는 **Windows용** 자격증명 헬퍼. Mac에 없는 헬퍼가 git 설정에 박혀 있어 헬퍼 실행이 실패하고, 수동 입력으로 떨어졌는데 GitHub는 비밀번호 로그인을 막아 놓았기 때문.
- **확인:**
  ```bash
  $ git config --show-origin --get-all credential.helper
  file:/Library/Developer/CommandLineTools/usr/share/git-core/gitconfig   osxkeychain
  file:/Users/gimnayeon/.gitconfig        winstore --timeout=3600
  ```
  시스템 기본값은 정상(`osxkeychain`)이고, 홈의 `~/.gitconfig`에 예전 Windows 설정이 남아 있던 것이 확인됨.
- **해결/대안:**
  ```bash
  $ git config --global --unset-all credential.helper   # 잘못된 헬퍼 제거
  $ gh auth login                                       # 브라우저 로그인 (one-time code)
  $ gh auth setup-git                                   # gh 를 git 자격증명 헬퍼로 등록
  $ git push -u origin main
   * [new branch]      main -> main
  ```
  대안: Personal Access Token을 발급해 Password 자리에 입력해도 됨. 단, 토큰은 절대 문서/로그에 남기지 않음.

### 7-2. 커스텀 이미지 접속 시 `403 Forbidden` (nginx)

- **문제:** `docker build` 성공, `docker run -p 8080:80` 성공, `docker port`도 정상인데 브라우저/curl 모두 `403 Forbidden`. (`logs/trouble-02-403-before.txt`, `screenshots/trouble-02-403-before.png`)
- **원인 가설:** 포트는 열렸으니 네트워크 문제가 아님. nginx가 파일을 "못 찾는 것"(404)이 아니라 "못 읽는 것"(403) → **파일 권한** 의심. 호스트의 `index.html`이 `-rw-------`(600)이었고, Dockerfile의 `COPY`는 권한을 그대로 복사하는데, nginx 워커 프로세스는 root가 아닌 `nginx` 사용자로 동작하므로 읽기 불가.
- **확인:**
  ```bash
  $ ls -l app/index.html
  -rw-------  1 gimnayeon  staff  881 11월  2 14:15 app/index.html

  $ docker logs web | grep error
  [error] 30#30: *1 open() "/usr/share/nginx/html/index.html" failed (13: Permission denied), ...
  ```
  컨테이너 로그에 `Permission denied`가 직접 찍혀 가설 확정. 반면 같은 파일을 **바인드 마운트**로 연결한 `logs/08`은 정상(200) — Docker Desktop이 Mac 폴더를 마운트할 때 권한을 느슨하게 매핑하기 때문. 같은 파일인데 COPY는 403, 마운트는 200이라는 대비가 원인을 뒷받침.
- **해결/대안:**
  1. 호스트 파일 권한 정리: `chmod 644 app/*`
  2. Dockerfile을 호스트 권한에 의존하지 않도록 수정: `COPY --chmod=644 index.html ...`
  3. 재빌드 후 `curl` → `HTTP 200` (`logs/07-port-mapping.txt`)

  5-2에서 배운 `644 = rw-r--r--`(그 외 사용자도 읽기 가능)가 실제 장애 해결에 그대로 쓰인 사례.

### 7-3. `docker run` 시 `Conflict. The container name "/web" is already in use`

- **문제:** 7-2 수정 후 스크립트를 재실행했더니 `docker run --name web`이 이름 충돌로 실패하고, 이어진 `curl`은 여전히 403. (`logs/trouble-03-name-conflict.txt`)
- **원인 가설:** 스크린샷을 찍으려고 수동으로 띄워 둔 **옛 이미지 기반의 `web` 컨테이너**가 아직 살아 있었음. 컨테이너 이름은 유일해야 하므로 새 컨테이너 생성이 거부되고, 8080 포트도 옛 컨테이너가 점유.
- **확인:**
  ```bash
  $ docker ps --filter name=web
  NAMES   IMAGE          STATUS                          PORTS
  web     367991098e2a   Up About a minute (unhealthy)   0.0.0.0:8080->80/tcp
  ```
  IMAGE가 새로 빌드한 `codyssey-web:v1`이 아니라 옛 이미지 ID이고, HEALTHCHECK도 `unhealthy`.
- **해결/대안:** `docker rm -f web` 으로 정리 후 재실행 → `Up (health: starting)` → `HTTP 200`. 교훈: "빌드는 됐는데 결과가 안 바뀐다"면 **실행 중인 컨테이너가 새 이미지를 쓰고 있는지**(`docker ps`의 IMAGE 열)부터 확인.

## 8. 배운 점 / 설계 원칙 정리

- **이미지와 컨테이너의 분리:** 이미지는 "읽기 전용 설계도"(`docker images`), 컨테이너는 그 설계도로 띄운 "실행 중인 인스턴스"(`docker ps`). 같은 `codyssey-web:v1`로 `web`, `web-bind`, compose 컨테이너를 각각 띄울 수 있었고, 컨테이너를 지워도 이미지는 남는다. 7-3처럼 **이미지를 새로 빌드해도 기존 컨테이너는 옛 이미지를 계속 쓴다**는 점이 둘이 분리되어 있다는 가장 직접적인 증거.
- **격리된 실행 환경:** `ubu-once` 안의 `hostname`, `/etc/os-release`, `/` 목록은 호스트(macOS)와 전혀 달랐고, 컨테이너 안에서 `/tmp/note.txt`를 만들어도 호스트에는 없다. 반대로 nginx 워커가 `nginx` 사용자라는 **컨테이너 내부의 권한 규칙**이 호스트 파일 권한과 충돌해 403이 난 것(7-2)도 격리의 한 단면.
- **포트·스토리지 연결 방식:** 격리돼 있으니 바깥과 연결하려면 명시적으로 뚫어야 한다. 네트워크는 `-p host:container`, 파일은 `-v`. 그중 바인드 마운트는 "개발 중 즉시 반영", 볼륨은 "컨테이너 수명과 무관한 영속 데이터"로 역할이 다르다.
- **Dockerfile vs Compose:** Dockerfile은 **이미지를 어떻게 만들지**(빌드), Compose는 **그 이미지를 어떤 설정으로 띄울지**(실행)를 적는다. `docker run -d --name web -p 8080:80 -v ... codyssey-web:v1` 같은 긴 명령을 매번 치는 대신 `docker-compose.yml`에 적어 두면 누구나 `docker compose up` 한 줄로 같은 환경을 재현한다. 이게 "컨테이너 실행 명령이 문서화된 실행 설정으로 바뀐다"는 뜻.
- **Git vs GitHub:** Git은 내 컴퓨터의 버전 관리 도구(`init/add/commit`), GitHub는 그 저장소를 올려 공유·협업하는 원격 플랫폼(`push/pull`). 7-1에서 겪었듯 둘을 잇는 **인증**이 별도 설정이다.

## 9. 보안 및 개인정보

- 로그/스크린샷에 토큰·비밀번호·개인키가 포함되지 않도록 확인했습니다. `gh auth login`의 one-time code는 일회성이며 문서에 남기지 않았습니다.
- `git config --list` 기록 시 `token`/`password` 값은 스크립트에서 `****`로 마스킹합니다.
- `.env`는 `.gitignore`로 제외하고 `.env.example`만 커밋했습니다.
- `docker info` 출력 중 로컬 경로 외 민감 정보는 없음을 확인했습니다.
