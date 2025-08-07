#!/bin/bash

# Docker 컨테이너 중지 자동화 스크립트
# 사용법: ./scripts/ensure_docker_stop.sh

set -e

echo "🛑 Docker 컨테이너 중지 시작..."

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
if docker compose -f services/hospital_workers/docker-compose.yml ps | grep -q "Up"; then
    echo "🛑 실행 중인 컨테이너 중지 중..."
    docker compose -f services/hospital_workers/docker-compose.yml down
    
    echo "🧹 컨테이너 및 네트워크 정리 중..."
    docker compose -f services/hospital_workers/docker-compose.yml down --remove-orphans
    
    echo "✅ Docker 컨테이너 중지 완료!"
else
    echo "ℹ️ 실행 중인 컨테이너가 없습니다."
fi

# 정리된 상태 확인
echo "📊 정리 상태 확인:"
docker compose -f services/hospital_workers/docker-compose.yml ps
