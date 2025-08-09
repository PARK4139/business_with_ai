#!/bin/bash

# Docker 설치 자동화 스크립트
# 사용법: ./scripts/ensure_containers_install.sh

set -e

echo "🐳 Docker 설치 시작..."

# Docker 설치 확인
if command -v docker > /dev/null 2>&1; then
    echo "✅ Docker 이미 설치됨"
    docker --version
    exit 0
fi

echo "📦 Docker 설치 중..."

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
    echo "🔧 Ubuntu/Debian 계열 Docker 설치..."
    
    # 패키지 업데이트
    sudo apt update
    
    # 필요한 패키지 설치
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Docker GPG 키 추가
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Docker 저장소 추가
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # 패키지 업데이트
    sudo apt update
    
    # Docker 설치
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    echo "🔧 CentOS/RHEL 계열 Docker 설치..."
    
    # EPEL 저장소 추가
    sudo yum install -y epel-release
    
    # Docker 저장소 추가
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
    # Docker 설치
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    
else
    echo "⚠️ 지원되지 않는 OS: $OS"
    echo "📋 수동 설치 방법:"
    echo "   curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "   sudo sh get-docker.sh"
    exit 1
fi

# Docker 서비스 시작
echo "🚀 Docker 서비스 시작..."
sudo systemctl start docker
sudo systemctl enable docker

# 현재 사용자를 docker 그룹에 추가
echo "👤 사용자를 docker 그룹에 추가..."
sudo usermod -aG docker $USER

# 설치 확인
if command -v docker > /dev/null 2>&1; then
    echo "✅ Docker 설치 완료!"
    docker --version
else
    echo "❌ Docker 설치 실패"
    exit 1
fi

echo "🧪 Docker 테스트..."
sudo docker run hello-world

echo "✅ Docker 설치 및 테스트 완료!"
echo "⚠️  중요: 새로운 그룹 권한을 적용하려면 시스템을 재로그인하거나 다음 명령어를 실행하세요:"
echo "   newgrp docker"
