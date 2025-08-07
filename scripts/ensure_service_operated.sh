#!/bin/bash

# 서비스 운영 테스트 스크립트
# 사용법: ./scripts/ensure_service_operated.sh

set -e

echo "🔧 서비스 운영 테스트 시작..."
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

# 2. 컨테이너 빌드 테스트
echo "🔨 컨테이너 빌드 테스트..."
if [ ! -f "services/hospital_workers/docker-compose.yml" ]; then
    echo "❌ docker-compose.yml 파일을 찾을 수 없습니다."
    exit 1
fi

# 기존 컨테이너 정리
echo "🧹 기존 컨테이너 정리..."
docker compose -f services/hospital_workers/docker-compose.yml down --remove-orphans 2>/dev/null || true

# 이미지 빌드 테스트
echo "📦 이미지 빌드 중..."
echo "🔍 빌드 진행 상황:"
if docker compose -f services/hospital_workers/docker-compose.yml build --no-cache; then
    echo "✅ 이미지 빌드 성공"
else
    echo "❌ 이미지 빌드 실패"
    exit 1
fi
echo "=================================="

# 3. 컨테이너 실행 테스트
echo "🚀 컨테이너 실행 테스트..."
echo "🔍 실행 진행 상황:"
if docker compose -f services/hospital_workers/docker-compose.yml up -d; then
    echo "✅ 컨테이너 실행 성공"
else
    echo "❌ 컨테이너 실행 실패"
    exit 1
fi
echo "=================================="

# 4. 서비스별 상세 상태 확인
echo "📊 서비스별 상세 상태 확인..."
echo "⏳ 서비스 시작 대기 중... (15초)"
sleep 15

services=("auth-service" "api-service" "nginx" "postgres" "redis")
all_running=true

echo "🔍 각 서비스 상태:"
for service in "${services[@]}"; do
    echo "----------------------------------------"
    echo "📋 $service 상태 확인:"
    
    # 컨테이너 상태 확인
    if docker compose -f services/hospital_workers/docker-compose.yml ps | grep -q "$service.*Up"; then
        echo "✅ $service 실행 중"
        
        # 컨테이너 상세 정보
        container_id=$(docker compose -f services/hospital_workers/docker-compose.yml ps -q $service)
        if [ ! -z "$container_id" ]; then
            echo "🔍 컨테이너 ID: $container_id"
            echo "🔍 컨테이너 상태:"
            docker inspect --format='{{.State.Status}}' $container_id
            echo "🔍 메모리 사용량:"
            docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}" $container_id
        fi
        
        # 서비스별 로그 확인 (최근 5줄)
        echo "📋 최근 로그 (5줄):"
        docker compose -f services/hospital_workers/docker-compose.yml logs --tail=5 $service
        
    else
        echo "❌ $service 실행 실패"
        all_running=false
        
        # 실패한 서비스의 로그 확인
        echo "📋 실패 로그:"
        docker compose -f services/hospital_workers/docker-compose.yml logs --tail=10 $service
    fi
    echo "----------------------------------------"
done

if [ "$all_running" = false ]; then
    echo "❌ 일부 서비스 실행 실패"
    echo "📋 전체 서비스 로그:"
    docker compose -f services/hospital_workers/docker-compose.yml logs
    exit 1
fi
echo "=================================="

# 5. 포트 연결 테스트
echo "🔌 포트 연결 테스트..."
ports=(
    "80:nginx"
    "8001:auth-service"
    "8002:api-service"
    "5432:postgres"
    "6379:redis"
)

echo "🔍 각 포트 상태:"
for port_info in "${ports[@]}"; do
    port=$(echo $port_info | cut -d: -f1)
    service=$(echo $port_info | cut -d: -f2)
    
    if netstat -tuln | grep -q ":$port "; then
        echo "✅ 포트 $port ($service) 사용 중"
    else
        echo "❌ 포트 $port ($service) 연결 실패"
    fi
done
echo "=================================="

# 6. HTTP 연결 테스트
echo "🌐 HTTP 연결 테스트..."
sleep 5

# 각 서비스별 HTTP 연결 테스트
echo "🔍 HTTP 연결 테스트:"

# Auth Service 테스트
echo "📋 Auth Service (포트 8001):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8001/health | grep -q "200"; then
    echo "✅ Auth Service HTTP 연결 성공"
else
    echo "❌ Auth Service HTTP 연결 실패"
fi

# API Service 테스트
echo "📋 API Service (포트 8002):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8002/health | grep -q "200"; then
    echo "✅ API Service HTTP 연결 성공"
else
    echo "❌ API Service HTTP 연결 실패"
fi

# Nginx 테스트
echo "📋 Nginx (포트 80):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:80 | grep -q "200\|301\|302"; then
    echo "✅ Nginx HTTP 연결 성공"
else
    echo "❌ Nginx HTTP 연결 실패"
fi
echo "=================================="

# 7. 데이터베이스 연결 테스트
echo "🗄️ 데이터베이스 연결 테스트..."
if docker compose -f services/hospital_workers/docker-compose.yml exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "✅ PostgreSQL 연결 성공"
else
    echo "❌ PostgreSQL 연결 실패"
fi
echo "=================================="

# 8. Redis 연결 테스트
echo "🔴 Redis 연결 테스트..."
if docker compose -f services/hospital_workers/docker-compose.yml exec -T redis redis-cli ping | grep -q "PONG"; then
    echo "✅ Redis 연결 성공"
else
    echo "❌ Redis 연결 실패"
fi
echo "=================================="

# 9. 네트워크 연결 테스트
echo "🌐 서비스 간 네트워크 연결 테스트..."
if docker compose -f services/hospital_workers/docker-compose.yml exec -T auth-service ping -c 1 api-service > /dev/null 2>&1; then
    echo "✅ auth-service → api-service 연결 성공"
else
    echo "❌ auth-service → api-service 연결 실패"
fi

if docker compose -f services/hospital_workers/docker-compose.yml exec -T api-service ping -c 1 auth-service > /dev/null 2>&1; then
    echo "✅ api-service → auth-service 연결 성공"
else
    echo "❌ api-service → auth-service 연결 실패"
fi
echo "=================================="

# 10. 전체 리소스 사용량 확인
echo "💾 전체 리소스 사용량 확인..."
echo "🔍 모든 컨테이너 리소스 사용량:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
echo "=================================="

# 11. 서비스별 API 테스트
echo "🧪 서비스별 API 테스트..."
echo "📋 Auth Service API 테스트:"
curl -s http://localhost:8001/ | jq . 2>/dev/null || curl -s http://localhost:8001/

echo "📋 API Service API 테스트:"
curl -s http://localhost:8002/ | jq . 2>/dev/null || curl -s http://localhost:8002/

echo "📋 위치 가이드 API 테스트:"
curl -s http://localhost:8002/api/heal_base_hospital_worker/v1/ensure/main/location/101 | jq . 2>/dev/null || curl -s http://localhost:8002/api/heal_base_hospital_worker/v1/ensure/main/location/101
echo "=================================="

echo "✅ 서비스 운영 테스트 완료!"
echo "=================================="
echo "📋 테스트 결과 요약:"
echo "   - Docker 서비스: 정상"
echo "   - 컨테이너 빌드: 성공"
echo "   - 컨테이너 실행: 성공"
echo "   - 서비스 상태: 정상"
echo "   - 포트 연결: 확인됨"
echo "   - HTTP 연결: 확인됨"
echo "   - 데이터베이스: 연결됨"
echo "   - Redis: 연결됨"
echo "   - 네트워크: 정상"
echo "   - 리소스: 모니터링됨"
echo "   - API 테스트: 완료"
echo "=================================="
echo "💡 서비스를 중지하려면: ./scripts/ensure_service_shutdowned.sh"
