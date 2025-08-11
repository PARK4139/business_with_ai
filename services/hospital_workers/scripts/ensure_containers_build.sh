#!/bin/bash

# Docker 컨테?�너 빌드 ?�동???�크립트
# ?�용�? ./scripts/ensure_containers_build.sh [dev|prod]

set -e

# ?�경 ?�정 (기본�? dev)
ENVIRONMENT=${1:-dev}

echo "?���?Docker 컨테?�너 빌드 ?�작... (?�경: $ENVIRONMENT)"

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
    echo "?�� ?�로?�션 ?�경 빌드"
else
    COMPOSE_FILE="../services/hospital_workers/docker-compose.dev.yml"
    echo "?�� 개발 ?�경 빌드"
fi

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "??$COMPOSE_FILE ?�일??찾을 ???�습?�다."
    exit 1
fi

# 기존 컨테?�너 ?�리
echo "?�� 기존 컨테?�너 ?�리 �?.."
docker compose -f "$COMPOSE_FILE" down --remove-orphans

# ?��?지 빌드
echo "?�� Docker ?��?지 빌드 �?.."
docker compose -f "$COMPOSE_FILE" build --no-cache

echo "??Docker 컨테?�너 빌드 ?�료! (?�경: $ENVIRONMENT)"
echo "?�� 빌드???�비??"
echo "   - auth-service (로그???�버)"
echo "   - api-service (API ?�버)"
echo "   - user-db (?�용???�이?�베?�스)"
echo "   - nginx (리버???�록??"
echo "   - redis (캐시/?�션)"
echo ""
echo "?�� ?�행 명령??"
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "   docker compose -f $COMPOSE_FILE up -d"
else
    echo "   docker compose -f $COMPOSE_FILE up -d"
fi
