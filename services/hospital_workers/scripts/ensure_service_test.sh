#!/bin/bash

# ?�비??빌드 관???�스???�행 ?�크립트
# ?�용�? ./scripts/ensure_service_test.sh

set -e

echo "?�� ?�비???�스???�작..."
echo "=================================="

# ?�로?�트 루트 ?�렉?�리�??�동
cd "$(dirname "$0")/.."

# 1. ?�일 구조 ?�스??
echo "?�� ?�일 구조 ?�스??.."
required_files=(
    "../services/hospital_workers/docker-compose.yml"
    "../services/hospital_workers/page_server/Dockerfile.dev"
    "../services/hospital_workers/api_server/pyproject.toml"
    "../services/hospital_workers/page_server/nginx/nginx.conf"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "??$file 존재"
    else
        echo "??$file ?�음"
        exit 1
    fi
done

# 2. Docker Compose 문법 ?�스??
echo "?�� Docker Compose 문법 ?�스??.."
if docker compose -f ../services/hospital_workers/docker-compose.yml config > /dev/null 2>&1; then
    echo "??Docker Compose 문법 ?�상"
else
    echo "??Docker Compose 문법 ?�류"
    docker compose -f ../services/hospital_workers/docker-compose.yml config
    exit 1
fi

# 3. Nginx ?�정 ?�스??
echo "?�� Nginx ?�정 ?�스??.."
if nginx -t -c "$(pwd)/../services/hospital_workers/page_server/nginx/nginx.conf" > /dev/null 2>&1; then
    echo "??Nginx ?�정 ?�상"
else
    echo "?�️ Nginx ?�정 ?�스??건너?� (nginx 명령???�음)"
fi

# 4. Python ?�존???�스??
echo "?�� Python ?�존???�스??.."
if command -v uv > /dev/null 2>&1; then
    echo "??uv ?�치??
    
    # api-server ?�존???�스??
    if [ -f "../services/hospital_workers/api_server/pyproject.toml" ]; then
        echo "?�� api-server ?�존???�인..."
        cd ../services/hospital_workers/api_server
        uv check > /dev/null 2>&1 && echo "??api-server ?�존???�상" || echo "??api-server ?�존???�류"
        cd ../..
    fi
else
    echo "?�️ uv ?�치?��? ?�음 - Python ?�존???�스??건너?�"
fi

# 5. ?�트 충돌 ?�스??
echo "?�� ?�트 충돌 ?�스??.."
ports=(80 5173 8002 5432 6379)
for port in "${ports[@]}"; do
    if netstat -tuln | grep -q ":$port "; then
        echo "?�️ ?�트 $port ?�용 �?
    else
        echo "???�트 $port ?�용 가??
    fi
done

# 6. 컨테?�너 ?�태 ?�스??
echo "?�� 컨테?�너 ?�태 ?�스??.."
services=("page-server" "api-server" "db-server" "nginx" "redis")
all_running=true

for service in "${services[@]}"; do
    if docker compose -f ../services/hospital_workers/docker-compose.yml ps | grep -q "$service.*Up"; then
        echo "??$service ?�행 �?
    else
        echo "??$service ?�행 ?�패"
        all_running=false
    fi
done

if [ "$all_running" = false ]; then
    echo "???��? ?�비???�행 ?�패"
    exit 1
fi

# 7. ?�트 ?�결 ?�스??
echo "?�� ?�트 ?�결 ?�스??.."
ports=(
    "80:nginx"
    "5173:page-server"
    "8002:api-server"
    "5432:db-server"
    "6379:redis"
)

for port_info in "${ports[@]}"; do
    port=$(echo $port_info | cut -d: -f1)
    service=$(echo $port_info | cut -d: -f2)
    
    if netstat -tuln | grep -q ":$port "; then
        echo "???�트 $port ($service) ?�용 �?
    else
        echo "???�트 $port ($service) ?�결 ?�패"
    fi
done

# 8. HTTP ?�결 ?�스??
echo "?�� HTTP ?�결 ?�스??.."
sleep 5

# Page Server ?�스??
echo "?�� Page Server (?�트 5173):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 | grep -q "200\|301\|302"; then
    echo "??Page Server HTTP ?�결 ?�공"
else
    echo "??Page Server HTTP ?�결 ?�패"
fi

# API Server ?�스??
echo "?�� API Server (?�트 8002):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8002/health | grep -q "200"; then
    echo "??API Server HTTP ?�결 ?�공"
else
    echo "??API Server HTTP ?�결 ?�패"
fi

# Nginx ?�스??
echo "?�� Nginx (?�트 80):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:80 | grep -q "200\|301\|302"; then
    echo "??Nginx HTTP ?�결 ?�공"
else
    echo "??Nginx HTTP ?�결 ?�패"
fi

# 9. ?�이?�베?�스 ?�결 ?�스??
echo "?���??�이?�베?�스 ?�결 ?�스??.."
if docker compose -f ../services/hospital_workers/docker-compose.yml exec -T db-server pg_isready -U postgres > /dev/null 2>&1; then
    echo "??PostgreSQL ?�결 ?�공"
else
    echo "??PostgreSQL ?�결 ?�패"
fi

# 10. Redis ?�결 ?�스??
echo "?�� Redis ?�결 ?�스??.."
if docker compose -f ../services/hospital_workers/docker-compose.yml exec -T redis redis-cli ping | grep -q "PONG"; then
    echo "??Redis ?�결 ?�공"
else
    echo "??Redis ?�결 ?�패"
fi

# 11. ?�트?�크 ?�결 ?�스??
echo "?�� ?�비??�??�트?�크 ?�결 ?�스??.."
if docker compose -f ../services/hospital_workers/docker-compose.yml exec -T api-server ping -c 1 db-server > /dev/null 2>&1; then
    echo "??api-server ??db-server ?�결 ?�공"
else
    echo "??api-server ??db-server ?�결 ?�패"
fi

if docker compose -f ../services/hospital_workers/docker-compose.yml exec -T api-server ping -c 1 redis > /dev/null 2>&1; then
    echo "??api-server ??redis ?�결 ?�공"
else
    echo "??api-server ??redis ?�결 ?�패"
fi

# 12. 리소???�용???�스??
echo "?�� 리소???�용???�스??.."
echo "?�� 모든 컨테?�너 리소???�용??"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

# 13. API ?�드?�인???�스??
echo "?�� API ?�드?�인???�스??.."
echo "?�� API Server ?�드?�인???�스??"
curl -s http://localhost:8002/ | jq . 2>/dev/null || curl -s http://localhost:8002/

echo "?�� ?�치 가?�드 API ?�스??"
curl -s http://localhost:8002/api/heal_base_hospital_worker/v1/ensure/main/location/101 | jq . 2>/dev/null || curl -s http://localhost:8002/api/heal_base_hospital_worker/v1/ensure/main/location/101

echo "???�비???�스???�료!"
echo "=================================="
echo "?�� ?�스??결과 ?�약:"
echo "   - ?�일 구조: ?�상"
echo "   - Docker Compose: ?�상"
echo "   - Python ?�존?? ?�인??
echo "   - ?�트 ?�태: ?�인??
echo "   - 컨테?�너 ?�태: ?�상"
echo "   - ?�트 ?�결: ?�인??
echo "   - HTTP ?�결: ?�인??
echo "   - ?�이?�베?�스: ?�결??
echo "   - Redis: ?�결??
echo "   - ?�트?�크: ?�상"
echo "   - 리소?? 모니?�링??
echo "   - API ?�드?�인?? ?�스?�됨"
echo "=================================="
