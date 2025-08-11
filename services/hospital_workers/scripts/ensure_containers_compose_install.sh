#!/bin/bash

# Docker Compose ?¤ì¹˜ ?ë™???¤í¬ë¦½íŠ¸
# ?¬ìš©ë²? ./scripts/ensure_containers_compose_install.sh

set -e

echo "?³ Docker Compose ?¤ì¹˜ ?œìž‘..."

# Docker Compose ?¤ì¹˜ ?•ì¸
if command -v docker-compose > /dev/null 2>&1; then
    echo "??Docker Compose ?´ë? ?¤ì¹˜??
    docker-compose --version
    exit 0
fi

# Docker ?¤ì¹˜ ?•ì¸
if ! command -v docker > /dev/null 2>&1; then
    echo "??Dockerê°€ ?¤ì¹˜?˜ì? ?Šì•˜?µë‹ˆ??"
    echo "?“‹ Docker ?¤ì¹˜ ë°©ë²•:"
    echo "   curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "   sudo sh get-docker.sh"
    exit 1
fi

echo "?“¦ Docker Compose ?¤ì¹˜ ì¤?.."

# Linux ë°°í¬???•ì¸
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo "??OS ?•ë³´ë¥??•ì¸?????†ìŠµ?ˆë‹¤."
    exit 1
fi

# Ubuntu/Debian ê³„ì—´
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    echo "?”§ Ubuntu/Debian ê³„ì—´ Docker Compose ?¤ì¹˜..."
    
    # ?¨í‚¤ì§€ ?…ë°?´íŠ¸
    sudo apt update
    
    # Docker Compose ?¤ì¹˜
    sudo apt install -y docker-compose-plugin
    
    # ?¬ë³¼ë¦?ë§í¬ ?ì„± (docker-compose ëª…ë ¹???¬ìš© ê°€?¥í•˜?„ë¡)
    if [ ! -f /usr/local/bin/docker-compose ]; then
        sudo ln -s /usr/bin/docker compose /usr/local/bin/docker-compose
    fi
    
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    echo "?”§ CentOS/RHEL ê³„ì—´ Docker Compose ?¤ì¹˜..."
    
    # EPEL ?€?¥ì†Œ ì¶”ê?
    sudo yum install -y epel-release
    
    # Docker Compose ?¤ì¹˜
    sudo yum install -y docker-compose-plugin
    
else
    echo "? ï¸ ì§€?ë˜ì§€ ?ŠëŠ” OS: $OS"
    echo "?“‹ ?˜ë™ ?¤ì¹˜ ë°©ë²•:"
    echo "   sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose"
    echo "   sudo chmod +x /usr/local/bin/docker-compose"
    exit 1
fi

# ?¤ì¹˜ ?•ì¸
if command -v docker-compose > /dev/null 2>&1; then
    echo "??Docker Compose ?¤ì¹˜ ?„ë£Œ!"
    docker-compose --version
else
    echo "??Docker Compose ?¤ì¹˜ ?¤íŒ¨"
    exit 1
fi

echo "?§ª Docker Compose ?ŒìŠ¤??.."
docker-compose --version

echo "??Docker Compose ?¤ì¹˜ ë°??ŒìŠ¤???„ë£Œ!"
