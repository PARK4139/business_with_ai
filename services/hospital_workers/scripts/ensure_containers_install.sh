#!/bin/bash

# Docker ?�치 ?�동???�크립트
# ?�용�? ./scripts/ensure_containers_install.sh

set -e

echo "?�� Docker ?�치 ?�작..."

# Docker ?�치 ?�인
if command -v docker > /dev/null 2>&1; then
    echo "??Docker ?��? ?�치??
    docker --version
    exit 0
fi

echo "?�� Docker ?�치 �?.."

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
    echo "?�� Ubuntu/Debian 계열 Docker ?�치..."
    
    # ?�키지 ?�데?�트
    sudo apt update
    
    # ?�요???�키지 ?�치
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Docker GPG ??추�?
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Docker ?�?�소 추�?
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # ?�키지 ?�데?�트
    sudo apt update
    
    # Docker ?�치
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    echo "?�� CentOS/RHEL 계열 Docker ?�치..."
    
    # EPEL ?�?�소 추�?
    sudo yum install -y epel-release
    
    # Docker ?�?�소 추�?
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
    # Docker ?�치
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    
else
    echo "?�️ 지?�되지 ?�는 OS: $OS"
    echo "?�� ?�동 ?�치 방법:"
    echo "   curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "   sudo sh get-docker.sh"
    exit 1
fi

# Docker ?�비???�작
echo "?? Docker ?�비???�작..."
sudo systemctl start docker
sudo systemctl enable docker

# ?�재 ?�용?��? docker 그룹??추�?
echo "?�� ?�용?��? docker 그룹??추�?..."
sudo usermod -aG docker $USER

# ?�치 ?�인
if command -v docker > /dev/null 2>&1; then
    echo "??Docker ?�치 ?�료!"
    docker --version
else
    echo "??Docker ?�치 ?�패"
    exit 1
fi

echo "?�� Docker ?�스??.."
sudo docker run hello-world

echo "??Docker ?�치 �??�스???�료!"
echo "?�️  중요: ?�로??그룹 권한???�용?�려�??�스?�을 ?�로그인?�거???�음 명령?��? ?�행?�세??"
echo "   newgrp docker"
