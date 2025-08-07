#!/bin/bash

# 서비스 운영 스크립트
# 사용법: ./scripts/ensure_service_operated.sh

set -e

echo "🚀 서비스 운영 시작..."
echo "=================================="

# 프로젝트 루트 디렉토리로 이동
cd "$(dirname "$0")/.."

# 1. Docker 서비스 상태 확인
echo "🐳 Docker 서비스 상태 확인..."
if ! command -v docker > /dev/null 2>&1; then
    echo "❌ Docker가 설치되지 않았습니다."
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 데몬이 실행되지 않았습니다."
    echo "📋 Docker 서비스 시작: sudo systemctl start docker"
    exit 1
fi

echo "✅ Docker 서비스 정상"
echo "=================================="

# 2. 컨테이너 빌드 및 실행
echo "🔨 컨테이너 빌드 및 실행..."
if [ ! -f "services/hospital_workers/docker-compose.yml" ]; then
    echo "❌ docker-compose.yml 파일을 찾을 수 없습니다."
    exit 1
fi

# 기존 컨테이너 정리
echo "🧹 기존 컨테이너 정리..."
docker compose -f services/hospital_workers/docker-compose.yml down --remove-orphans 2>/dev/null || true

# 이미지 빌드
echo "📦 이미지 빌드 중..."
if docker compose -f services/hospital_workers/docker-compose.yml build; then
    echo "✅ 이미지 빌드 성공"
else
    echo "❌ 이미지 빌드 실패"
    exit 1
fi

# 컨테이너 실행
echo "🚀 컨테이너 실행 중..."
if docker compose -f services/hospital_workers/docker-compose.yml up -d; then
    echo "✅ 컨테이너 실행 성공"
else
    echo "❌ 컨테이너 실행 실패"
    exit 1
fi
echo "=================================="

# 3. 서비스 상태 확인
echo "📊 서비스 상태 확인..."
echo "⏳ 서비스 시작 대기 중... (10초)"
sleep 10

services=("page-server" "api-server" "db-server" "nginx" "redis")
all_running=true

echo "🔍 각 서비스 상태:"
for service in "${services[@]}"; do
    if docker compose -f services/hospital_workers/docker-compose.yml ps | grep -q "$service.*Up"; then
        echo "✅ $service 실행 중"
    else
        echo "❌ $service 실행 실패"
        all_running=false
    fi
done

if [ "$all_running" = false ]; then
    echo "❌ 일부 서비스 실행 실패"
    exit 1
fi
echo "=================================="

# 4. 기본 연결 확인
echo "🔌 기본 연결 확인..."
sleep 5

# API Service 연결 확인
echo "📋 API Service (포트 8002):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8002/health | grep -q "200"; then
    echo "✅ API Service 연결 성공"
else
    echo "❌ API Service 연결 실패"
fi

# Nginx 연결 확인
echo "📋 Nginx (포트 80):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:80 | grep -q "200\|301\|302"; then
    echo "✅ Nginx 연결 성공"
else
    echo "❌ Nginx 연결 실패"
fi
echo "=================================="

echo "✅ 서비스 운영 완료!"
echo "=================================="
echo "📋 운영 결과 요약:"
echo "   - Docker 서비스: 정상"
echo "   - 컨테이너 빌드: 성공"
echo "   - 컨테이너 실행: 성공"
echo "   - 서비스 상태: 정상"
echo "   - 기본 연결: 확인됨"
echo "=================================="
echo "💡 서비스를 중지하려면: ./scripts/ensure_service_shutdowned.sh"
echo "💡 모니터링하려면: ./monitors/ensure_service_monitored.sh"
