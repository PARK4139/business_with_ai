#!/bin/bash

# Docker Compose ?�치 ?�동???�크립트
# ?�용�? ./scripts/ensure_containers_compose_install.sh

set -e

echo "?�� Docker Compose ?�치 ?�작..."

# Docker Compose ?�치 ?�인
if command -v docker-compose > /dev/null 2>&1; then
    echo "??Docker Compose ?��? ?�치??
    docker-compose --version
    exit 0
fi

# Docker ?�치 ?�인
if ! command -v docker > /dev/null 2>&1; then
    echo "??Docker가 ?�치?��? ?�았?�니??"
    echo "?�� Docker ?�치 방법:"
    echo "   curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "   sudo sh get-docker.sh"
    exit 1
fi

echo "?�� Docker Compose ?�치 �?.."

# Linux 배포???�인
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo "??OS ?�보�??�인?????�습?�다."
    exit 1
fi

# Ubuntu/Debian 계열
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    echo "?�� Ubuntu/Debian 계열 Docker Compose ?�치..."
    
    # ?�키지 ?�데?�트
    sudo apt update
    
    # Docker Compose ?�치
    sudo apt install -y docker-compose-plugin
    
    # ?�볼�?링크 ?�성 (docker-compose 명령???�용 가?�하?�록)
    if [ ! -f /usr/local/bin/docker-compose ]; then
        sudo ln -s /usr/bin/docker compose /usr/local/bin/docker-compose
    fi
    
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    echo "?�� CentOS/RHEL 계열 Docker Compose ?�치..."
    
    # EPEL ?�?�소 추�?
    sudo yum install -y epel-release
    
    # Docker Compose ?�치
    sudo yum install -y docker-compose-plugin
    
else
    echo "?�️ 지?�되지 ?�는 OS: $OS"
    echo "?�� ?�동 ?�치 방법:"
    echo "   sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose"
    echo "   sudo chmod +x /usr/local/bin/docker-compose"
    exit 1
fi

# ?�치 ?�인
if command -v docker-compose > /dev/null 2>&1; then
    echo "??Docker Compose ?�치 ?�료!"
    docker-compose --version
else
    echo "??Docker Compose ?�치 ?�패"
    exit 1
fi

echo "?�� Docker Compose ?�스??.."
docker-compose --version

echo "??Docker Compose ?�치 �??�스???�료!"
