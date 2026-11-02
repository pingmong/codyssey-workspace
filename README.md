# AI/SW 개발 워크스페이스 구축

> Codyssey 입학연수 Pre-course · Dev Setup 미션 수행 기록
> 처음 보는 분은 👉 **[GUIDE.md](GUIDE.md)** (단계별 설명서)부터 읽어 주세요. 이 문서는 제출용 요약입니다.

## 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [실행 환경](#2-실행-환경)
3. [저장소 구조](#3-저장소-구조)
4. [수행 항목 체크리스트](#4-수행-항목-체크리스트)
5. [수행 내용 요약](#5-수행-내용-요약)
6. [보너스 과제](#6-보너스-과제)
7. [트러블슈팅](#7-트러블슈팅)
8. [배운 점](#8-배운-점)
9. [보안 및 개인정보](#9-보안-및-개인정보)

## 1. 프로젝트 개요

터미널·Docker·Git을 직접 세팅하고, "내 컴퓨터에서만 돌아가는" 환경이 아니라 **누가 실행해도 같은 결과가 나오는** 개발 워크스테이션을 만드는 미션입니다.

한 일을 한 줄로 요약하면: 터미널로 디렉토리·권한을 정리하고 → Docker를 점검·운영하고 → NGINX 베이스로 커스텀 이미지를 만들어 → 포트/마운트/볼륨을 검증하고 → Git/GitHub/VSCode를 연동했습니다. 보너스로 Compose 단일·멀티, 환경 변수, SSH까지 진행했습니다.

모든 실습은 `scripts/` 의 스크립트로 **순서대로 실행하고 결과를 `logs/` 에 자동 기록**했습니다. 본문은 요약이고, 전체 출력은 각 로그 파일에 있습니다.

## 2. 실행 환경

| 항목 | 값 |
|---|---|
| OS | macOS 26.7.1 (Apple Silicon, arm64) |
| 셸 / 터미널 | zsh + Bash 스크립트 |
| Docker | 29.8.1 (Docker Desktop) / Compose v5.5.1 |
| Git | 2.50.1 (Apple Git-155) + gh CLI 2.103.3 |
| 에디터 | VSCode |

## 3. 저장소 구조

```
.
├── app/                 # 커스텀 이미지 소스 (Dockerfile + index.html)
├── compose-single/      # 보너스: 단일 서비스 Compose (+ .env.example)
├── compose-multi/       # 보너스: 웹 + Redis 멀티 컨테이너 Compose
├── scripts/             # 실습 스크립트 4개 (01 터미널 → 04 보너스)
├── logs/                # 실행 로그 (증거). trouble-* 는 실패 당시 로그
├── screenshots/         # 브라우저 접속, VSCode-GitHub 연동 캡처
├── README.md            # 제출용 요약 (이 문서)
└── GUIDE.md             # 수강생용 단계별 설명서
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
| 11 | 보안: 토큰/비밀번호 마스킹 | ✅ | 본 문서, `.gitignore`, `logs/10` 마스킹 |
| B1 | Compose 단일 서비스 | ✅ | `logs/11-compose-single.txt` |
| B2 | Compose 멀티 컨테이너 + 네트워크 통신 | ✅ | `logs/12-compose-multi.txt` |
| B3 | Compose 운영 명령 (up/down/ps/logs) | ✅ | `logs/11`, `logs/12` |
| B4 | 환경 변수로 포트 변경 | ✅ | `logs/13-env-var.txt` |
| B5 | GitHub SSH 키 | ✅ | `logs/14-ssh.txt` |

## 5. 수행 내용 요약

### 5-1. 터미널 조작 · 권한 — `logs/01`, `logs/02`

```bash
$ pwd && ls -la                       # 현재 위치, 숨김 파일 포함 목록
$ mkdir -p scratch && touch scratch/empty.txt
$ echo 'hello workspace' > scratch/hello.txt && cat scratch/hello.txt
$ cp scratch/hello.txt scratch/hello-copy.txt && mv scratch/hello-copy.txt scratch/renamed.txt
$ rm scratch/empty.txt
```

| 대상 | 변경 전 | 명령 | 변경 후 | 효과 |
|---|---|---|---|---|
| `perm.sh` | `-rw-r--r--` → `Permission denied` | `chmod 755` | `-rwxr-xr-x` → `run ok` | 실행 권한 부여 |
| `perm.sh` | `-rwxr-xr-x` | `chmod 644` | `-rw-r--r--` → 다시 `denied` | 실행 권한 회수 |
| `perm-dir/` | `drwxr-xr-x` | `chmod 700` | `drwx------` | 소유자만 접근 |

### 5-2. Docker 점검 · 운영 · 컨테이너 실습 — `logs/03`~`05`

```bash
$ docker --version            # Docker version 29.8.1
$ docker info                 # Server Version 29.8.1 / Docker Desktop / 8 CPU
$ docker run --name hello hello-world          # "Hello from Docker!"
$ docker run --name ubu-once ubuntu bash -c 'hostname; cat /etc/os-release | head -2'
$ docker run -d --name ubu-keep ubuntu sleep 600 && docker exec ubu-keep bash -c 'whoami'
$ docker ps -a --filter name=ubu-
ubu-keep   Up                 "sleep 600"      ← 메인 프로세스가 살아 있으면 Up
ubu-once   Exited (0)         "bash -c ..."    ← 끝나면 함께 종료
$ docker images / ps / ps -a / logs hello / stats --no-stream / stop / start / rm -f
```

### 5-3. 커스텀 이미지 (방식 A: `nginx:alpine` + 정적 페이지) — `logs/06`

```dockerfile
FROM nginx:alpine
COPY --chmod=644 index.html /usr/share/nginx/html/index.html   # 기본 페이지 교체 (+권한 고정)
EXPOSE 80                                                       # 사용 포트 문서화
HEALTHCHECK --interval=10s --timeout=3s CMD wget -qO- http://localhost/ > /dev/null || exit 1
```

```bash
$ docker build -t codyssey-web:v1 ./app     # → codyssey-web:v1 (26.3MB)
$ docker run -d --name web -p 8080:80 codyssey-web:v1
```

### 5-4. 포트 매핑 접속 — `logs/07`, `screenshots/port-mapping.png`

```bash
$ docker port web
80/tcp -> 0.0.0.0:8080
$ curl -s -o /dev/null -w 'HTTP %{http_code}\n' http://localhost:8080
HTTP 200
```

![port mapping](screenshots/port-mapping.png)

### 5-5. 바인드 마운트 vs 볼륨 — `logs/08`, `logs/09`

```bash
# 바인드 마운트: 호스트 파일 수정 → 재시작 없이 즉시 반영
$ docker run -d --name web-bind -p 8080:80 -v "$(pwd)/app:/usr/share/nginx/html:ro" nginx:alpine
$ curl -s localhost:8080 | grep -o 'badge">[^<]*'     # badge">v1
$ sed -i '' 's/v1/v2-bind-mount/' app/index.html
$ curl -s localhost:8080 | grep -o 'badge">[^<]*'     # badge">v2-bind-mount

# 볼륨: 컨테이너를 지워도 데이터 유지
$ docker volume create codyssey-data
$ docker run --rm -v codyssey-data:/data alpine sh -c 'echo "written at $(date)" >> /data/persist.txt'
$ docker run --rm -v codyssey-data:/data alpine cat /data/persist.txt
written at Mon Nov  2 05:30:56 UTC 2026                 ← 이전 컨테이너가 쓴 데이터 그대로
# 비교: 볼륨 없이 쓴 /data-no-vol.txt 는 다음 컨테이너에서 "No such file"
```

### 5-6. Git · GitHub · VSCode — `logs/10`, `screenshots/vscode-github.png`

```bash
$ git config --list --show-origin | grep -E 'user\.|init\.|credential'
user.name=pingmong / user.email=****@**** / init.defaultbranch=main
credential.https://github.com.helper=!/opt/homebrew/bin/gh auth git-credential
$ git remote -v      # origin git@github.com:pingmong/codyssey-workspace.git
```

![vscode github](screenshots/vscode-github.png)

## 6. 보너스 과제

| | 한 일 | 핵심 결과 | 배움 포인트 |
|---|---|---|---|
| B1 | `compose-single/` 단일 서비스 `up -d --build` → `ps` → `curl` → `down` | `HTTP 200 on :8080` | `docker run` 긴 명령이 yml 8줄로 "문서화" |
| B2 | `compose-multi/` 웹 + Redis | web → `getent hosts cache` = `172.21.0.2`, `nc -zv cache 6379` = open, `redis-cli ping` = PONG | 서비스 이름이 곧 호스트 이름 (서비스 디스커버리) |
| B3 | `up` / `ps` / `logs --tail` / `down` 루틴 | 네트워크·컨테이너 자동 생성·정리 | 운영 "상태 확인 루틴" |
| B4 | `.env`의 `WEB_PORT=9090`만으로 포트 변경, `docker run -e APP_MODE=production` | `HTTP 200 on :9090` | 설정과 코드의 분리 |
| B5 | 기존 ed25519 키로 `ssh -T git@github.com` → 원격을 SSH로 전환 | `Hi pingmong! You've successfully authenticated` | 토큰(HTTPS) vs 키 쌍(SSH), 개인키는 절대 공유 금지 |

상세 로그: `logs/11`~`14`. 설명은 [GUIDE.md 보너스 섹션](GUIDE.md#보너스-docker-compose).

## 7. 트러블슈팅

| # | 문제 | 원인 | 확인 | 해결 |
|---|---|---|---|---|
| 7-1 | `git push` → `git: 'credential-winstore' is not a git command`, 비밀번호 입력해도 인증 실패 | `~/.gitconfig`에 **Windows용** 자격증명 헬퍼가 남아 있음 + GitHub는 비밀번호 로그인 불가 | `git config --show-origin --get-all credential.helper` → `~/.gitconfig  winstore --timeout=3600` | `--unset-all credential.helper` → `gh auth login` → `gh auth setup-git` → push 성공 |
| 7-2 | 커스텀 이미지 접속 시 `403 Forbidden` (포트는 정상) | 호스트 `index.html`이 `600`인 채로 `COPY`됨 → 비root `nginx` 워커가 읽기 불가 | `docker logs web` → `open() ".../index.html" failed (13: Permission denied)`. 같은 파일 바인드 마운트는 200 | `chmod 644` + Dockerfile `COPY --chmod=644` → 재빌드 → `HTTP 200` |
| 7-3 | 재실행 시 `Conflict. The container name "/web" is already in use`, 여전히 403 | 스크린샷용으로 띄운 **옛 이미지** 컨테이너가 살아서 이름·포트 점유 | `docker ps` IMAGE 열이 새 이미지가 아님, `unhealthy` | `docker rm -f web` 후 재실행 |
| 7-4 | `git add .` → `fatal: CRLF would be replaced by LF in logs/...` | 403 응답 본문(HTTP는 CRLF)이 로그에 섞임 + `core.safecrlf` 보호 | `grep -rl $'\r' logs` → 1개 파일 | `sed -i 's/\r//g'` 후 add. 대안 `.gitattributes` `*.txt text eol=lf` |

각 항목의 전/후 로그: `logs/trouble-02-403-before.txt`, `logs/trouble-02-build-before.txt`, `logs/trouble-03-name-conflict.txt`, `screenshots/trouble-02-403-before.png`. 자세한 서술은 [GUIDE.md 트러블슈팅](GUIDE.md#트러블슈팅-막혔던-곳과-푼-방법).

## 8. 배운 점

- **이미지 ≠ 컨테이너.** 이미지는 설계도, 컨테이너는 그걸로 띄운 인스턴스. 새로 빌드해도 **기존 컨테이너는 옛 이미지를 계속 쓴다**(7-3)는 게 둘이 분리돼 있다는 가장 직접적인 증거.
- **격리.** 컨테이너 안의 hostname·OS·파일시스템·사용자(`nginx`)는 호스트와 다르다. 그래서 호스트 파일 권한이 컨테이너 안에서 문제(7-2)가 될 수 있다.
- **연결은 명시적으로.** 네트워크는 `-p host:container`, 파일은 `-v`. 바인드 마운트는 "개발 중 즉시 반영", 볼륨은 "컨테이너 수명과 무관한 영속 데이터".
- **Dockerfile vs Compose.** Dockerfile은 이미지를 *어떻게 만들지*(빌드), Compose는 그걸 *어떤 설정으로 띄울지*(실행). 실행 명령을 파일로 문서화하면 누구나 `docker compose up` 한 줄로 재현한다.
- **Git vs GitHub.** Git은 내 컴퓨터의 버전 관리, GitHub는 공유·협업 플랫폼. 둘을 잇는 인증(HTTPS 토큰 / SSH 키)은 별도 설정이고, 꼬이면 7-1처럼 된다.

## 9. 보안 및 개인정보

- 로그·스크린샷에 토큰, 비밀번호, 개인키가 없음을 확인했습니다. `gh auth login`의 one-time code는 일회성이며 기록하지 않았습니다.
- `logs/10-git-config.txt`의 `user.email`, `user.signingkey`는 `****`로 마스킹했습니다.
- `.env`는 `.gitignore`로 제외하고 `.env.example`만 커밋했습니다.
- SSH 개인키(`~/.ssh/id_ed25519`)는 저장소 밖에 있으며, 공개키 경로만 로그에 남겼습니다.
