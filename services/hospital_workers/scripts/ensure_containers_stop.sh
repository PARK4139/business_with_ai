#!/bin/bash

# Docker 컨테?�너 중�? ?�동???�크립트
# ?�용�? ./scripts/ensure_containers_stop.sh

set -e

echo "?�� Docker 컨테?�너 중�? ?�작..."

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
if docker compose -f ../services/hospital_workers/docker-compose.yml ps | grep -q "Up"; then
    echo "?�� ?�행 중인 컨테?�너 중�? �?.."
    docker compose -f ../services/hospital_workers/docker-compose.yml down
    
    echo "?�� 컨테?�너 �??�트?�크 ?�리 �?.."
    docker compose -f ../services/hospital_workers/docker-compose.yml down --remove-orphans
    
    echo "??Docker 컨테?�너 중�? ?�료!"
else
    echo "?�️ ?�행 중인 컨테?�너가 ?�습?�다."
fi

# ?�리???�태 ?�인
echo "?�� ?�리 ?�태 ?�인:"
docker compose -f ../services/hospital_workers/docker-compose.yml ps
