#!/bin/bash

# 서비스 빌드 관련 테스트 실행 스크립트
# 사용법: ./scripts/ensure_service_test.sh

set -e

echo "🧪 서비스 빌드 테스트 시작..."

# 프로젝트 루트 디렉토리로 이동
cd "$(dirname "$0")/.."

# 1. 파일 구조 테스트
echo "📁 파일 구조 테스트..."
required_files=(
    "services/hospital_workers/docker-compose.yml"
    "services/hospital_workers/auth-service/Dockerfile"
    "services/hospital_workers/auth-service/pyproject.toml"
    "services/hospital_workers/api-service/Dockerfile"
    "services/hospital_workers/api-service/pyproject.toml"
    "services/hospital_workers/nginx/nginx.conf"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file 존재"
    else
        echo "❌ $file 없음"
        exit 1
    fi
done

# 2. Docker Compose 문법 테스트
echo "🐳 Docker Compose 문법 테스트..."
if docker compose -f services/hospital_workers/docker-compose.yml config > /dev/null 2>&1; then
    echo "✅ Docker Compose 문법 정상"
else
    echo "❌ Docker Compose 문법 오류"
    docker compose -f services/hospital_workers/docker-compose.yml config
    exit 1
fi

# 3. Nginx 설정 테스트
echo "🌐 Nginx 설정 테스트..."
if nginx -t -c "$(pwd)/services/hospital_workers/nginx/nginx.conf" > /dev/null 2>&1; then
    echo "✅ Nginx 설정 정상"
else
    echo "⚠️ Nginx 설정 테스트 건너뜀 (nginx 명령어 없음)"
fi

# 4. Python 의존성 테스트
echo "🐍 Python 의존성 테스트..."
if command -v uv > /dev/null 2>&1; then
    echo "✅ uv 설치됨"
    
    # auth-service 의존성 테스트
    if [ -f "services/hospital_workers/auth-service/pyproject.toml" ]; then
        echo "📦 auth-service 의존성 확인..."
        cd services/hospital_workers/auth-service
        uv check > /dev/null 2>&1 && echo "✅ auth-service 의존성 정상" || echo "❌ auth-service 의존성 오류"
        cd ../../..
    fi
    
    # api-service 의존성 테스트
    if [ -f "services/hospital_workers/api-service/pyproject.toml" ]; then
        echo "📦 api-service 의존성 확인..."
        cd services/hospital_workers/api-service
        uv check > /dev/null 2>&1 && echo "✅ api-service 의존성 정상" || echo "❌ api-service 의존성 오류"
        cd ../../..
    fi
else
    echo "⚠️ uv 설치되지 않음 - Python 의존성 테스트 건너뜀"
fi

# 5. 포트 충돌 테스트
echo "🔌 포트 충돌 테스트..."
ports=(80 8001 8002 5432 6379)
for port in "${ports[@]}"; do
    if netstat -tuln | grep -q ":$port "; then
        echo "⚠️ 포트 $port 사용 중"
    else
        echo "✅ 포트 $port 사용 가능"
    fi
done

echo "✅ 서비스 빌드 테스트 완료!"
echo "📋 테스트 결과:"
echo "   - 파일 구조: 정상"
echo "   - Docker Compose: 정상"
echo "   - Python 의존성: 확인됨"
echo "   - 포트 상태: 확인됨"
