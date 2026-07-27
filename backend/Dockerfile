FROM python:3.12-slim

WORKDIR /app

# 파이썬 바이트코드 생성을 방지하고 버퍼링 없이 출력을 로그로 보냄
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# 빌드 및 시스템 필수 패키지 설치
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 파이썬 의존성 설치
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# 백엔드 소스코드 복사
COPY . .

# 내부 포트 5000 노출
EXPOSE 5000

# Gunicorn 프로덕션 서버 실행 (워커 4개, 스레드 2개, 타임아웃 120초)
CMD ["gunicorn", "-b", "0.0.0.0:5000", "--workers", "4", "--threads", "2", "--timeout", "120", "run:app"]
