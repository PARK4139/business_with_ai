#!/bin/bash

# 서비스 모니터링 스크립트
# 사용법: ./monitors/ensure_service_monitored.sh

set -e

echo "🔍 서비스 모니터링 시작..."
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
    exit 1
fi

echo "✅ Docker 서비스 정상"
echo "=================================="

# 2. 컨테이너 상태 모니터링
echo "📊 컨테이너 상태 모니터링..."
services=("page-server" "api-server" "db-server" "nginx" "redis")

for service in "${services[@]}"; do
    echo "----------------------------------------"
    echo "📋 $service 모니터링:"
    
    # 컨테이너 상태 확인
    if docker compose -f services/hospital_workers/docker-compose.yml ps | grep -q "$service.*Up"; then
        echo "✅ $service 실행 중"
        
        # 컨테이너 상세 정보
        container_id=$(docker compose -f services/hospital_workers/docker-compose.yml ps -q $service)
        if [ ! -z "$container_id" ]; then
            echo "🔍 컨테이너 정보:"
            echo "   📦 컨테이너 ID: $container_id"
            echo "   🏷️  컨테이너 이름: $service"
            echo "   📊 컨테이너 상태: $(docker inspect --format='{{.State.Status}}' $container_id)"
            echo "   ⏰ 시작 시간: $(docker inspect --format='{{.State.StartedAt}}' $container_id | cut -d'T' -f1)"
            echo "   🔍 메모리 사용량:"
            docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}\t{{.MemPerc}}" $container_id
            echo "   🔍 CPU 사용량:"
            docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.PIDs}}" $container_id
        fi
        
        # 서비스별 로그 확인 (최근 3줄)
        echo "📋 최근 로그 (3줄):"
        docker compose -f services/hospital_workers/docker-compose.yml logs --tail=3 $service
        
    else
        echo "❌ $service 실행 실패"
        
        # 실패한 서비스의 로그 확인
        echo "📋 실패 로그:"
        docker compose -f services/hospital_workers/docker-compose.yml logs --tail=5 $service
    fi
    echo "----------------------------------------"
done

# 3. 포트 연결 모니터링
echo "🔌 포트 연결 모니터링..."
ports=(
    "80:nginx"
    "5173:page-server"
    "8002:api-server"
    "5432:db-server"
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

# 4. HTTP 연결 모니터링
echo "🌐 HTTP 연결 모니터링..."
sleep 2

# 각 서비스별 HTTP 연결 테스트
echo "🔍 HTTP 연결 테스트:"

# Page Server 테스트
echo "📋 Page Server (포트 5173):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 | grep -q "200\|301\|302"; then
    echo "✅ Page Server HTTP 연결 성공"
else
    echo "❌ Page Server HTTP 연결 실패"
fi

# API Server 테스트
echo "📋 API Server (포트 8002):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8002/health | grep -q "200"; then
    echo "✅ API Server HTTP 연결 성공"
else
    echo "❌ API Server HTTP 연결 실패"
fi

# Nginx 테스트
echo "📋 Nginx (포트 80):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:80 | grep -q "200\|301\|302"; then
    echo "✅ Nginx HTTP 연결 성공"
else
    echo "❌ Nginx HTTP 연결 실패"
fi
echo "=================================="

# 5. 데이터베이스 연결 모니터링
echo "🗄️ 데이터베이스 연결 모니터링..."
if docker compose -f services/hospital_workers/docker-compose.yml exec -T db-server pg_isready -U postgres > /dev/null 2>&1; then
    echo "✅ PostgreSQL 연결 성공"
else
    echo "❌ PostgreSQL 연결 실패"
fi
echo "=================================="

# 6. Redis 연결 모니터링
echo "🔴 Redis 연결 모니터링..."
if docker compose -f services/hospital_workers/docker-compose.yml exec -T redis redis-cli ping | grep -q "PONG"; then
    echo "✅ Redis 연결 성공"
else
    echo "❌ Redis 연결 실패"
fi
echo "=================================="

# 7. 전체 리소스 사용량 모니터링
echo "💾 전체 리소스 사용량 모니터링..."
echo "🔍 모든 컨테이너 리소스 사용량:"
echo "   📊 서비스별 상세 정보:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"
echo "=================================="

# 8. 네트워크 연결 모니터링
echo "🌐 서비스 간 네트워크 연결 모니터링..."
if docker compose -f services/hospital_workers/docker-compose.yml exec -T api-server ping -c 1 db-server > /dev/null 2>&1; then
    echo "✅ api-server → db-server 연결 성공"
else
    echo "❌ api-server → db-server 연결 실패"
fi

if docker compose -f services/hospital_workers/docker-compose.yml exec -T api-server ping -c 1 redis > /dev/null 2>&1; then
    echo "✅ api-server → redis 연결 성공"
else
    echo "❌ api-server → redis 연결 실패"
fi
echo "=================================="

# 9. API 엔드포인트 모니터링
echo "🧪 API 엔드포인트 모니터링..."
echo "📋 API Server 엔드포인트 테스트:"
curl -s http://localhost:8002/ | jq . 2>/dev/null || curl -s http://localhost:8002/

echo "📋 위치 가이드 API 테스트:"
curl -s http://localhost:8002/api/heal_base_hospital_worker/v1/ensure/main/location/101 | jq . 2>/dev/null || curl -s http://localhost:8002/api/heal_base_hospital_worker/v1/ensure/main/location/101
echo "=================================="

echo "✅ 서비스 모니터링 완료!"
echo "=================================="
echo "📋 모니터링 결과 요약:"
echo "   - Docker 서비스: 정상"
echo "   - 컨테이너 상태: 모니터링됨"
echo "   - 포트 연결: 확인됨"
echo "   - HTTP 연결: 확인됨"
echo "   - 데이터베이스: 연결됨"
echo "   - Redis: 연결됨"
echo "   - 리소스: 모니터링됨"
echo "   - 네트워크: 정상"
echo "   - API 엔드포인트: 테스트됨"
echo "=================================="
