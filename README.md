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

## 2. 실행 환경

| 항목 | 값 |
|---|---|
| OS | _(채움 예정)_ |
| 셸 / 터미널 | _(채움 예정)_ |
| Docker | _(채움 예정)_ |
| Docker Compose | _(채움 예정)_ |
| Git | _(채움 예정)_ |
| 에디터 | VSCode |

## 3. 저장소 구조

```
.
├── app/                    # 커스텀 이미지 소스 (Dockerfile + index.html)
├── compose-single/         # 보너스: 단일 서비스 Compose
├── compose-multi/          # 보너스: 웹 + Redis 멀티 컨테이너 Compose
├── scripts/                # 실습 명령을 순서대로 실행하고 logs/ 에 기록하는 스크립트
├── logs/                   # 실제 실행 로그 (증거)
├── screenshots/            # 브라우저 접속, VSCode-GitHub 연동 캡처
└── README.md
```

## 4. 수행 항목 체크리스트

| # | 항목 | 상태 | 증거 |
|---|---|---|---|
| 1 | 터미널 조작 (pwd, ls -la, mkdir, cp, mv, rm, touch, cat) | ⬜ | `logs/01-terminal.txt` |
| 2 | 권한 확인/변경 (파일 1 + 디렉토리 1, 전/후 비교) | ⬜ | `logs/02-permission.txt` |
| 3 | Docker 설치 점검 (`docker --version`, `docker info`) | ⬜ | `logs/03-docker-check.txt` |
| 4 | Docker 기본 운영 (images, ps, logs, stats, stop/start/rm) | ⬜ | `logs/04-docker-ops.txt` |
| 5 | hello-world / ubuntu 실행, attach vs exec 관찰 | ⬜ | `logs/05-container-practice.txt` |
| 6 | Dockerfile 커스텀 이미지 빌드·실행 | ⬜ | `logs/06-build-run.txt` |
| 7 | 포트 매핑 접속 증거 | ⬜ | `logs/07-port-mapping.txt`, `screenshots/port-mapping.png` |
| 8 | 바인드 마운트 변경 반영 (전/후) | ⬜ | `logs/08-bind-mount.txt` |
| 9 | Docker 볼륨 영속성 (컨테이너 삭제 전/후) | ⬜ | `logs/09-volume.txt` |
| 10 | Git 설정 + GitHub/VSCode 연동 | ⬜ | `logs/10-git-config.txt`, `screenshots/vscode-github.png` |
| 11 | 보안: 토큰/비밀번호 마스킹 | ⬜ | 본 문서 전체 |
| B1 | Compose 단일 서비스 | ⬜ | `logs/11-compose-single.txt` |
| B2 | Compose 멀티 컨테이너 + 네트워크 통신 | ⬜ | `logs/12-compose-multi.txt` |
| B3 | Compose 운영 명령 (up/down/ps/logs) | ⬜ | `logs/11`, `logs/12` |
| B4 | 환경 변수로 포트 변경 | ⬜ | `logs/13-env-var.txt` |
| B5 | GitHub SSH 키 | ⬜ | `logs/14-ssh.txt` |

## 5. 수행 내용

### 5-1. 터미널 조작

_(logs/01-terminal.txt 요약 채움 예정)_

### 5-2. 권한 실습

_(logs/02-permission.txt 요약 채움 예정)_

### 5-3. Docker 설치 및 기본 점검

_(채움 예정)_

### 5-4. Docker 기본 운영 명령

_(채움 예정)_

### 5-5. 컨테이너 실행 실습 (hello-world, ubuntu, attach vs exec)

_(채움 예정)_

### 5-6. 커스텀 이미지 제작 (Dockerfile)

**선택한 베이스:** `nginx:alpine` (방식 A — 웹 서버 베이스 이미지 + 정적 콘텐츠 교체)

**커스텀 포인트:**

| # | 변경 | 목적 |
|---|---|---|
| 1 | `COPY index.html /usr/share/nginx/html/` | NGINX 기본 환영 페이지를 우리 페이지로 교체 |
| 2 | `EXPOSE 80` | 컨테이너가 사용하는 포트를 문서화 (실제 개방은 `-p`가 담당) |
| 3 | `HEALTHCHECK` | 컨테이너가 살아있어도 서비스가 죽었는지 Docker가 감지하도록 |

_(빌드/실행 로그 채움 예정)_

### 5-7. 포트 매핑 접속 증거

_(채움 예정)_

### 5-8. 바인드 마운트 vs 볼륨

_(채움 예정)_

### 5-9. Git 설정 및 GitHub/VSCode 연동

_(채움 예정)_

## 6. 보너스 과제

### B1. Docker Compose 단일 서비스

_(채움 예정)_

### B2·B3. 멀티 컨테이너 + 운영 명령

_(채움 예정)_

### B4. 환경 변수 활용

_(채움 예정)_

### B5. GitHub SSH 키

_(채움 예정)_

## 7. 트러블슈팅

### 7-1. _(제목 채움 예정)_

- **문제:**
- **원인 가설:**
- **확인:**
- **해결/대안:**

### 7-2. _(제목 채움 예정)_

- **문제:**
- **원인 가설:**
- **확인:**
- **해결/대안:**

## 8. 배운 점 / 설계 원칙 정리

- **이미지와 컨테이너의 분리:**
- **격리된 실행 환경:**
- **포트·스토리지 연결 방식:**
- **Dockerfile vs Compose:**

## 9. 보안 및 개인정보

- 로그/스크린샷에 토큰·비밀번호·개인키가 포함되지 않도록 확인했습니다.
- `.env` 는 `.gitignore` 로 제외하고 `.env.example` 만 커밋했습니다.
