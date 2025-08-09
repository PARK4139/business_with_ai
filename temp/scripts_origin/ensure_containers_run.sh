#!/bin/bash

# Docker 컨테이너 실행 자동화 스크립트
# 사용법: ./scripts/ensure_containers_run.sh [dev|prod]

set -e

# 환경 설정 (기본값: dev)
ENVIRONMENT=${1:-dev}

echo "🚀 Docker 컨테이너 실행 시작... (환경: $ENVIRONMENT)"

# 프로젝트 루트 디렉토리로 이동
cd "$(dirname "$0")/.."

# 서비스 디렉토리 확인
if [ ! -d "services/hospital_workers" ]; then
    echo "❌ services/hospital_workers 디렉토리를 찾을 수 없습니다."
    exit 1
fi

# 환경별 Docker Compose 파일 확인
if [ "$ENVIRONMENT" = "prod" ]; then
    COMPOSE_FILE="services/hospital_workers/docker-compose.prod.yml"
    echo "🔧 프로덕션 환경 실행"
else
    COMPOSE_FILE="services/hospital_workers/docker-compose.dev.yml"
    echo "🔧 개발 환경 실행"
fi

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ $COMPOSE_FILE 파일을 찾을 수 없습니다."
    exit 1
fi

# 기존 컨테이너 중지
echo "🛑 기존 컨테이너 중지 중..."
sudo docker compose -f "$COMPOSE_FILE" down

# 컨테이너 실행
echo "▶️ Docker 컨테이너 실행 중..."
sudo docker compose -f "$COMPOSE_FILE" up -d

# 서비스 상태 확인
echo "📊 서비스 상태 확인 중..."
sleep 10

# 각 서비스 상태 확인
services=("auth-service" "api-service" "frontend" "nginx" "user-db" "redis")
for service in "${services[@]}"; do
    if sudo docker compose -f "$COMPOSE_FILE" ps | grep -q "$service.*Up"; then
        echo "✅ $service 실행 중"
    else
        echo "❌ $service 실행 실패"
    fi
done

echo "✅ Docker 컨테이너 실행 완료! (환경: $ENVIRONMENT)"
echo "🌐 서비스 접속 정보:"
echo "   - 메인 서비스: http://localhost"
echo "   - 프론트엔드 (직접): http://localhost:5173"
echo "   - 인증 서비스: http://localhost:8001"
echo "   - API 서비스: http://localhost:8002"
echo "   - 데이터베이스: localhost:5432"
echo "   - Redis: localhost:6379"

if [ "$ENVIRONMENT" = "dev" ]; then
    echo ""
    echo "💡 개발 모드 특징:"
    echo "   - 코드 변경사항 즉시 반영"
    echo "   - 볼륨 마운트로 빠른 개발"
    echo "   - --reload 옵션으로 자동 재시작"
    echo "   - 프론트엔드 Hot Reload 지원"
    echo "   - React + Vite 개발 환경"
fi
