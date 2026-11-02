# 기존 베이스: 공식 NGINX 이미지(alpine 계열, 약 40MB로 가벼움)
FROM nginx:alpine

# 커스텀 포인트 1: 기본 환영 페이지를 우리 정적 페이지로 교체
#   --chmod=644 : 호스트 파일 권한이 600이어도 nginx 워커(비root)가 읽을 수 있게 고정
COPY --chmod=644 index.html /usr/share/nginx/html/index.html

# 커스텀 포인트 2: 컨테이너가 80번 포트를 사용한다는 것을 문서화 (실제 개방은 -p 옵션이 담당)
EXPOSE 80

# 커스텀 포인트 3: 헬스체크 — nginx가 정상 응답하는지 10초마다 확인
HEALTHCHECK --interval=10s --timeout=3s CMD wget -qO- http://localhost/ > /dev/null || exit 1
