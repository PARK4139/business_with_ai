#!/bin/bash
set -e

echo "?? ?�비???�영 ?�작..."
echo "=================================="

# ?�로?�트 루트 ?�렉?�리�??�동
cd "$(dirname "$0")/.."

# 1. Docker ?�비???�태 ?�인
echo "?�� Docker ?�비???�태 ?�인..."
if ! command -v docker > /dev/null 2>&1; then
    echo "??Docker가 ?�치?��? ?�았?�니??"
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    echo "??Docker ?�몬???�행?��? ?�았?�니??"
    echo "?�� Docker ?�비???�작: sudo systemctl start docker"
    exit 1
fi

echo "??Docker ?�비???�상"
echo "=================================="

# 2. 컨테?�너 빌드 �??�행
echo "?�� 컨테?�너 빌드 �??�행..."
if [ ! -f "../services/hospital_workers/docker-compose.yml" ]; then
    echo "??docker-compose.yml ?�일??찾을 ???�습?�다."
    exit 1
fi

# 기존 컨테?�너 ?�리
echo "?�� 기존 컨테?�너 ?�리..."
docker compose -f ../services/hospital_workers/docker-compose.yml down --remove-orphans 2>/dev/null || true

# ?��?지 빌드
echo "?�� ?��?지 빌드 �?.."
if docker compose -f ../services/hospital_workers/docker-compose.yml build; then
    echo "???��?지 빌드 ?�공"
else
    echo "???��?지 빌드 ?�패"
    exit 1
fi

# 컨테?�너 ?�행
echo "?? 컨테?�너 ?�행 �?.."
if docker compose -f ../services/hospital_workers/docker-compose.yml up -d; then
    echo "??컨테?�너 ?�행 ?�공"
else
    echo "??컨테?�너 ?�행 ?�패"
    exit 1
fi
echo "=================================="

# 3. ?�비???�태 ?�인
echo "?�� ?�비???�태 ?�인..."
echo "???�비???�작 ?��?�?.. (10�?"
sleep 10

services=("page-server" "api-server" "db-server" "nginx" "redis")
all_running=true

echo "?�� �??�비???�태:"
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
echo "=================================="

# 4. 기본 ?�결 ?�인
echo "?�� 기본 ?�결 ?�인..."
sleep 5

# API Service ?�결 ?�인
echo "?�� API Service (?�트 8002):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8002/health | grep -q "200"; then
    echo "??API Service ?�결 ?�공"
else
    echo "??API Service ?�결 ?�패"
fi

# Nginx ?�결 ?�인
echo "?�� Nginx (?�트 80):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:80 | grep -q "200\|301\|302"; then
    echo "??Nginx ?�결 ?�공"
else
    echo "??Nginx ?�결 ?�패"
fi
echo "=================================="

echo "???�비???�영 ?�료!"
echo "=================================="
echo "?�� ?�영 결과 ?�약:"
echo "   - Docker ?�비?? ?�상"
echo "   - 컨테?�너 빌드: ?�공"
echo "   - 컨테?�너 ?�행: ?�공"
echo "   - ?�비???�태: ?�상"
echo "   - 기본 ?�결: ?�인??
echo "=================================="
echo "?�� ?�비?��? 중�??�려�? ./scripts/ensure_service_shutdowned.sh"
echo "?�� 모니?�링?�려�? ./monitors/ensure_service_monitored.sh"
