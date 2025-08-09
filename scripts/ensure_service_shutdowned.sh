#!/bin/bash

# 서비스 중지 스크립트
# 사용법: ./scripts/ensure_service_shutdowned.sh

set -e

echo "🛑 서비스 중지 시작..."
echo "=================================="

# 프로젝트 루트 디렉토리로 이동
cd "$(dirname "$0")/.."

# 서비스 디렉토리 확인
if [ ! -d "services/hospital_workers" ]; then
    echo "❌ services/hospital_workers 디렉토리를 찾을 수 없습니다."
    exit 1
fi

# Docker Compose 파일 확인
if [ ! -f "services/hospital_workers/docker-compose.yml" ]; then
    echo "❌ docker-compose.yml 파일을 찾을 수 없습니다."
    exit 1
fi

# 실행 중인 컨테이너 확인
echo "📊 현재 실행 중인 서비스 확인..."
if docker compose -f services/hospital_workers/docker-compose.yml ps | grep -q "Up"; then
    echo "🔍 실행 중인 서비스:"
    docker compose -f services/hospital_workers/docker-compose.yml ps
    
    echo "=================================="
    echo "🛑 서비스 중지 중..."
    
    # 서비스별 순차 중지
    services=("nginx" "api-service" "auth-service" "redis" "postgres")
    
    for service in "${services[@]}"; do
        echo "🛑 $service 중지 중..."
        if docker compose -f services/hospital_workers/docker-compose.yml stop $service; then
            echo "✅ $service 중지 완료"
        else
            echo "❌ $service 중지 실패"
        fi
        sleep 2
    done
    
    echo "=================================="
    echo "🧹 컨테이너 및 네트워크 정리 중..."
    
    # 모든 컨테이너 중지 및 정리
    if docker compose -f services/hospital_workers/docker-compose.yml down --remove-orphans; then
        echo "✅ 모든 서비스 중지 및 정리 완료"
    else
        echo "❌ 서비스 중지 실패"
        exit 1
    fi
    
    echo "=================================="
    echo "📊 정리 후 상태 확인:"
    docker compose -f services/hospital_workers/docker-compose.yml ps
    
else
    echo "ℹ️ 실행 중인 서비스가 없습니다."
fi

echo "=================================="
echo "✅ 서비스 중지 완료!"
echo "📋 중지된 서비스:"
echo "   - nginx (리버스 프록시)"
echo "   - api-service (API 서버)"
echo "   - auth-service (인증 서버)"
echo "   - redis (캐시/세션)"
echo "   - postgres (데이터베이스)"
echo "=================================="
echo "💡 서비스를 다시 시작하려면: ./scripts/ensure_containers_run.sh"
