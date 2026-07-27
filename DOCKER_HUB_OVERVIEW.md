# SportsMate (Docker Compose)

## 프로젝트 개요

- React/Vite 프론트엔드와 Flask 백엔드를 각각 독립된 Docker 이미지로 제공합니다.
- 프론트엔드는 Nginx를 통해 웹 화면을 제공하고 `/api` 요청을 백엔드로 전달합니다.
- 백엔드는 Flask와 Gunicorn으로 API를 제공합니다.
- Docker Compose가 두 컨테이너를 같은 내부 네트워크로 연결합니다.
- 사용자는 하나의 주소 `http://localhost`로 전체 애플리케이션을 이용합니다.

## Docker 이미지

- Frontend: `carrotkang/sportsmate-frontend:latest`
- Backend: `carrotkang/sportsmate-backend:latest`

## 1. Docker Compose 파일 다운로드

아래 파일을 내려받아 `docker-compose.local.yml`이라는 이름으로 저장합니다.

[docker-compose.example.yml 다운로드](https://raw.githubusercontent.com/sagwajusu/sportsmate/carrotkang/docker-compose.example.yml)

Compose 실행 시 프론트엔드와 백엔드 이미지는 Docker Hub에서 자동으로 다운로드되므로 `docker pull`을 각각 실행할 필요가 없습니다.

## 2. 백엔드 환경변수 준비

백엔드에는 데이터베이스, JWT, Supabase 및 외부 API 환경변수가 필요합니다.

[backend/.env.example 확인](https://github.com/sagwajusu/sportsmate/blob/carrotkang/backend/.env.example)

Compose 파일이 있는 위치에 `backend` 폴더를 만들고 예시 파일을 `.env`라는 이름으로 저장한 다음 실제 값을 입력합니다.

```text
backend/.env
```

실제 `.env`에는 민감한 키가 포함되므로 GitHub, Docker Hub 또는 다른 사람에게 공유하지 마세요.

## 3. Docker Compose 실행

```bash
docker compose -f docker-compose.local.yml pull
docker compose -f docker-compose.local.yml up -d
docker compose -f docker-compose.local.yml ps
```

## 4. 접속

```text
http://localhost
```

백엔드 상태 확인:

```text
http://localhost/api/health
```

## 5. 종료

```bash
docker compose -f docker-compose.local.yml down
```

## 서비스 구조

```text
사용자
  ↓ http://localhost
Frontend (React + Nginx, port 80)
  ↓ Docker 내부 네트워크
Backend (Flask + Gunicorn, port 5000)
  ↓
PostgreSQL / Supabase
```
