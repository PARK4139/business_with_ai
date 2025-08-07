#!/bin/bash

# Docker 컨테이너 빌드 자동화 스크립트
# 사용법: ./scripts/ensure_docker_build.sh [dev|prod]

set -e

# 환경 설정 (기본값: dev)
ENVIRONMENT=${1:-dev}

echo "🏗️ Docker 컨테이너 빌드 시작... (환경: $ENVIRONMENT)"

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
    echo "🔧 프로덕션 환경 빌드"
else
    COMPOSE_FILE="services/hospital_workers/docker-compose.dev.yml"
    echo "🔧 개발 환경 빌드"
fi

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ $COMPOSE_FILE 파일을 찾을 수 없습니다."
    exit 1
fi

# 기존 컨테이너 정리
echo "🧹 기존 컨테이너 정리 중..."
docker compose -f "$COMPOSE_FILE" down --remove-orphans

# 이미지 빌드
echo "🔨 Docker 이미지 빌드 중..."
docker compose -f "$COMPOSE_FILE" build --no-cache

echo "✅ Docker 컨테이너 빌드 완료! (환경: $ENVIRONMENT)"
echo "📋 빌드된 서비스:"
echo "   - auth-service (로그인 서버)"
echo "   - api-service (API 서버)"
echo "   - user-db (사용자 데이터베이스)"
echo "   - nginx (리버스 프록시)"
echo "   - redis (캐시/세션)"
echo ""
echo "💡 실행 명령어:"
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "   docker compose -f $COMPOSE_FILE up -d"
else
    echo "   docker compose -f $COMPOSE_FILE up -d"
fi
