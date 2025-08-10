#!/bin/bash

# Docker 컨테?�너 ?�행 ?�동???�크립트
# ?�용�? ./scripts/ensure_containers_run.sh [dev|prod]

set -e

# ?�경 ?�정 (기본�? dev)
ENVIRONMENT=${1:-dev}

echo "?? Docker 컨테?�너 ?�행 ?�작... (?�경: $ENVIRONMENT)"

# ?�로?�트 루트 ?�렉?�리�??�동
cd "$(dirname "$0")/.."

# ?�비???�렉?�리 ?�인
if [ ! -d "../services/hospital_workers" ]; then
    echo "??../services/hospital_workers ?�렉?�리�?찾을 ???�습?�다."
    exit 1
fi

# ?�경�?Docker Compose ?�일 ?�인
if [ "$ENVIRONMENT" = "prod" ]; then
    COMPOSE_FILE="../services/hospital_workers/docker-compose.prod.yml"
    echo "?�� ?�로?�션 ?�경 ?�행"
else
    COMPOSE_FILE="../services/hospital_workers/docker-compose.dev.yml"
    echo "?�� 개발 ?�경 ?�행"
fi

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "??$COMPOSE_FILE ?�일??찾을 ???�습?�다."
    exit 1
fi

# 기존 컨테?�너 중�?
echo "?�� 기존 컨테?�너 중�? �?.."
sudo docker compose -f "$COMPOSE_FILE" down

# 컨테?�너 ?�행
echo "?�️ Docker 컨테?�너 ?�행 �?.."
sudo docker compose -f "$COMPOSE_FILE" up -d

# ?�비???�태 ?�인
echo "?�� ?�비???�태 ?�인 �?.."
sleep 10

# �??�비???�태 ?�인
services=("auth-service" "api-service" "frontend" "nginx" "user-db" "redis")
for service in "${services[@]}"; do
    if sudo docker compose -f "$COMPOSE_FILE" ps | grep -q "$service.*Up"; then
        echo "??$service ?�행 �?
    else
        echo "??$service ?�행 ?�패"
    fi
done

echo "??Docker 컨테?�너 ?�행 ?�료! (?�경: $ENVIRONMENT)"
echo "?�� ?�비???�속 ?�보:"
echo "   - 메인 ?�비?? http://localhost"
echo "   - ?�론?�엔??(직접): http://localhost:5173"
echo "   - ?�증 ?�비?? http://localhost:8001"
echo "   - API ?�비?? http://localhost:8002"
echo "   - ?�이?�베?�스: localhost:5432"
echo "   - Redis: localhost:6379"

if [ "$ENVIRONMENT" = "dev" ]; then
    echo ""
    echo "?�� 개발 모드 ?�징:"
    echo "   - 코드 변경사??즉시 반영"
    echo "   - 볼륨 마운?�로 빠른 개발"
    echo "   - --reload ?�션?�로 ?�동 ?�시??
    echo "   - ?�론?�엔??Hot Reload 지??
    echo "   - React + Vite 개발 ?�경"
fi
