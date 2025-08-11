#!/bin/bash

# ?�비??중�? ?�크립트
# ?�용�? ./scripts/ensure_service_shutdowned.sh

set -e

echo "?�� ?�비??중�? ?�작..."
echo "=================================="

# ?�로?�트 루트 ?�렉?�리�??�동
cd "$(dirname "$0")/.."

# ?�비???�렉?�리 ?�인
if [ ! -d "../services/hospital_workers" ]; then
    echo "??../services/hospital_workers ?�렉?�리�?찾을 ???�습?�다."
    exit 1
fi

# Docker Compose ?�일 ?�인
if [ ! -f "../services/hospital_workers/docker-compose.yml" ]; then
    echo "??docker-compose.yml ?�일??찾을 ???�습?�다."
    exit 1
fi

# ?�행 중인 컨테?�너 ?�인
echo "?�� ?�재 ?�행 중인 ?�비???�인..."
if docker compose -f ../services/hospital_workers/docker-compose.yml ps | grep -q "Up"; then
    echo "?�� ?�행 중인 ?�비??"
    docker compose -f ../services/hospital_workers/docker-compose.yml ps
    
    echo "=================================="
    echo "?�� ?�비??중�? �?.."
    
    # ?�비?�별 ?�차 중�?
    services=("nginx" "api-service" "auth-service" "redis" "postgres")
    
    for service in "${services[@]}"; do
        echo "?�� $service 중�? �?.."
        if docker compose -f ../services/hospital_workers/docker-compose.yml stop $service; then
            echo "??$service 중�? ?�료"
        else
            echo "??$service 중�? ?�패"
        fi
        sleep 2
    done
    
    echo "=================================="
    echo "?�� 컨테?�너 �??�트?�크 ?�리 �?.."
    
    # 모든 컨테?�너 중�? �??�리
    if docker compose -f ../services/hospital_workers/docker-compose.yml down --remove-orphans; then
        echo "??모든 ?�비??중�? �??�리 ?�료"
    else
        echo "???�비??중�? ?�패"
        exit 1
    fi
    
    echo "=================================="
    echo "?�� ?�리 ???�태 ?�인:"
    docker compose -f ../services/hospital_workers/docker-compose.yml ps
    
else
    echo "?�️ ?�행 중인 ?�비?��? ?�습?�다."
fi

echo "=================================="
echo "???�비??중�? ?�료!"
echo "?�� 중�????�비??"
echo "   - nginx (리버???�록??"
echo "   - api-service (API ?�버)"
echo "   - auth-service (?�증 ?�버)"
echo "   - redis (캐시/?�션)"
echo "   - postgres (?�이?�베?�스)"
echo "=================================="
echo "?�� ?�비?��? ?�시 ?�작?�려�? ./scripts/ensure_containers_run.sh"
