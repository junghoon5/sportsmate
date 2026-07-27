# SportsMate

SportsMate는 위치와 관심 종목을 기반으로 운동 모임을 찾고, 참여하고, 운영할 수 있는 스포츠 커뮤니티 플랫폼입니다.

일회성·정기 운동 모임의 생성부터 참여 신청, 실시간 채팅, 일정과 출석 관리까지 하나의 서비스에서 제공합니다. 하나의 React 애플리케이션 안에 PC와 모바일 전용 UI를 각각 구현했으며, 접속한 기기에 맞는 화면을 자동으로 표시합니다.

## 프로젝트 구성

- **Frontend**: React, Vite, Nginx
- **Backend**: Python, Flask, Gunicorn, SQLAlchemy
- **Database**: PostgreSQL / Supabase
- **Realtime & Storage**: Supabase Realtime, Supabase Storage
- **External APIs**: OpenAI, 지도·장소 검색, 기상 정보
- **Deployment**: Docker Compose

## 주요 기능

### 모임 탐색과 참여

- 종목·지역·키워드 및 현재 위치를 기준으로 운동 모임 검색
- 일회성 모임과 반복 일정이 있는 정기모임 지원
- 참여 신청, 방장 승인·거절, 신청 취소와 정원 관리
- 모임 상세 정보, 일정, 후기, 공지와 투표 제공

### 채팅과 알림

- 모임별 실시간 채팅과 사용자 간 1:1 채팅
- 답장, 이미지 및 위치 공유, 읽음 상태와 메시지 신고
- 채팅방 고정, 알림 끄기, 나가기 기능
- Web Push 기반 서비스 알림

### 방장용 모임 운영

- 참여 신청자와 모임 멤버 관리
- 정기모임 회차 생성·변경·취소
- 공지와 투표 생성
- QR 및 수동 출석 체크
- 참여율과 모임 운영 통계

### AI와 생활 정보

- 사용자 선호 종목과 활동 지역을 반영한 모임 추천
- 자연어를 이용한 지역·종목 검색
- 현재 참여 중인 모임 일정 안내
- 현재 위치와 지정 지역의 날씨 정보 제공

### 계정과 관리자

- 이메일, Google, Kakao 로그인
- 프로필, 선호 종목, 활동 지역과 자기소개 관리
- 사용자·모임·신고·문의·공지 관리
- 서비스 통계, 일괄 알림, 감사 로그와 점검 모드

## PC와 모바일 UI

SportsMate는 단순히 화면 폭만 줄이는 방식이 아니라 PC와 모바일에 적합한 레이아웃과 주요 화면을 각각 구현했습니다.

- **PC UI**: 넓은 화면에 맞춘 사이드바, 상세 정보와 관리 기능 중심의 레이아웃
- **Mobile UI**: 터치 조작과 작은 화면에 맞춘 모바일 헤더·하단 탐색, 모바일 전용 채팅과 모임 관리 화면
- **자동 전환**: 브라우저의 기기 정보를 확인해 PC 또는 모바일 UI를 자동으로 선택
- **수동 전환**: 테스트를 위해 URL의 `device` 옵션으로 원하는 UI를 강제로 표시

## Docker 이미지

- Frontend: `carrotkang/sportsmate-frontend:latest`
- Backend: `carrotkang/sportsmate-backend:latest`

두 이미지는 별도로 배포되지만 Docker Compose가 하나의 애플리케이션으로 연결합니다.

```text
사용자
  ↓ HTTP port 80
Frontend (React + Nginx)
  ↓ /api 요청 · Docker 내부 네트워크
Backend (Flask + Gunicorn, port 5000)
  ↓
PostgreSQL / Supabase
```

## 1. Docker Compose 파일 다운로드

아래 파일을 내려받아 `docker-compose.local.yml`이라는 이름으로 저장합니다.

[docker-compose.example.yml 다운로드](https://raw.githubusercontent.com/sagwajusu/sportsmate/carrotkang/docker-compose.example.yml)

Compose가 프론트엔드와 백엔드 이미지를 Docker Hub에서 자동으로 내려받으므로 `docker pull`을 각각 실행할 필요가 없습니다.

## 2. 백엔드 환경변수 준비

백엔드에는 데이터베이스, JWT, Supabase 및 외부 API 환경변수가 필요합니다.

[backend/.env.example 확인](https://github.com/sagwajusu/sportsmate/blob/carrotkang/backend/.env.example)

Compose 파일이 있는 위치에 `backend` 폴더를 만들고 예시 파일을 `.env`라는 이름으로 저장한 뒤 실제 값을 입력합니다.

```text
배포 폴더/
├─ docker-compose.local.yml
└─ backend/
   └─ .env
```

실제 `.env`에는 민감한 키가 포함되므로 GitHub, Docker Hub 또는 다른 사람에게 공유하지 마세요.

## 3. Docker Compose 실행

```bash
docker compose -f docker-compose.local.yml pull
docker compose -f docker-compose.local.yml up -d
docker compose -f docker-compose.local.yml ps
```

`frontend`와 `backend` 컨테이너가 실행되고 백엔드 상태가 `healthy`로 표시되면 준비가 완료된 것입니다.

## 4. PC 화면과 모바일 화면

SportsMate는 PC용 URL과 모바일용 URL이 완전히 분리된 구조가 아닙니다. 동일한 애플리케이션이 브라우저의 기기 정보를 감지해 PC 또는 모바일 전용 레이아웃을 자동으로 선택합니다.

### 자동 화면 선택

```text
http://localhost
```

- PC 브라우저로 접속하면 PC 레이아웃이 표시됩니다.
- 실제 스마트폰으로 접속하면 모바일 레이아웃이 표시됩니다.

### PC 화면 강제 실행

```text
http://localhost/?device=desktop
```

### 모바일 화면 강제 실행

PC에서도 모바일 전용 화면을 확인할 수 있습니다.

```text
http://localhost/?device=mobile
```

`device` 선택은 브라우저에 저장됩니다. 화면을 다시 변경하려면 원하는 주소의 `device=desktop` 또는 `device=mobile`로 다시 접속합니다.

## 5. 실제 스마트폰에서 접속

스마트폰의 `localhost`는 스마트폰 자신을 의미하므로 PC에서 실행 중인 SportsMate에 연결되지 않습니다. PC와 스마트폰을 같은 Wi-Fi에 연결하고 PC의 IPv4 주소를 사용해야 합니다.

예를 들어 PC의 IPv4 주소가 `192.168.0.15`라면:

```text
자동 모바일 화면: http://192.168.0.15
모바일 강제 화면: http://192.168.0.15/?device=mobile
PC 강제 화면:     http://192.168.0.15/?device=desktop
```

PC의 IPv4 주소는 Windows에서 다음 명령으로 확인할 수 있습니다.

```cmd
ipconfig
```

다른 기기에서 접속하려면 Windows 방화벽에서 TCP 80번 포트가 허용되어 있어야 합니다.

## 6. 백엔드 상태 확인

```text
http://localhost/api/health
```

정상 응답:

```json
{"status":"ok"}
```

## 7. 종료

```bash
docker compose -f docker-compose.local.yml down
```
