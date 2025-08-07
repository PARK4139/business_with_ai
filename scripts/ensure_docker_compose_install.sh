#!/bin/bash

# Docker Compose 설치 자동화 스크립트
# 사용법: ./scripts/ensure_docker_compose_install.sh

set -e

echo "🐳 Docker Compose 설치 시작..."

# Docker Compose 설치 확인
if command -v docker-compose > /dev/null 2>&1; then
    echo "✅ Docker Compose 이미 설치됨"
    docker-compose --version
    exit 0
fi

# Docker 설치 확인
if ! command -v docker > /dev/null 2>&1; then
    echo "❌ Docker가 설치되지 않았습니다."
    echo "📋 Docker 설치 방법:"
    echo "   curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "   sudo sh get-docker.sh"
    exit 1
fi

echo "📦 Docker Compose 설치 중..."

# Linux 배포판 확인
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo "❌ OS 정보를 확인할 수 없습니다."
    exit 1
fi

# Ubuntu/Debian 계열
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    echo "🔧 Ubuntu/Debian 계열 Docker Compose 설치..."
    
    # 패키지 업데이트
    sudo apt update
    
    # Docker Compose 설치
    sudo apt install -y docker-compose-plugin
    
    # 심볼릭 링크 생성 (docker-compose 명령어 사용 가능하도록)
    if [ ! -f /usr/local/bin/docker-compose ]; then
        sudo ln -s /usr/bin/docker compose /usr/local/bin/docker-compose
    fi
    
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    echo "🔧 CentOS/RHEL 계열 Docker Compose 설치..."
    
    # EPEL 저장소 추가
    sudo yum install -y epel-release
    
    # Docker Compose 설치
    sudo yum install -y docker-compose-plugin
    
else
    echo "⚠️ 지원되지 않는 OS: $OS"
    echo "📋 수동 설치 방법:"
    echo "   sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose"
    echo "   sudo chmod +x /usr/local/bin/docker-compose"
    exit 1
fi

# 설치 확인
if command -v docker-compose > /dev/null 2>&1; then
    echo "✅ Docker Compose 설치 완료!"
    docker-compose --version
else
    echo "❌ Docker Compose 설치 실패"
    exit 1
fi

echo "🧪 Docker Compose 테스트..."
docker-compose --version

echo "✅ Docker Compose 설치 및 테스트 완료!"
