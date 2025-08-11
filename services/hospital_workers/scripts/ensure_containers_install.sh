#!/bin/bash

# Docker ?¤ì¹˜ ?ë™???¤í¬ë¦½íŠ¸
# ?¬ìš©ë²? ./scripts/ensure_containers_install.sh

set -e

echo "?³ Docker ?¤ì¹˜ ?œì‘..."

# Docker ?¤ì¹˜ ?•ì¸
if command -v docker > /dev/null 2>&1; then
    echo "??Docker ?´ë? ?¤ì¹˜??
    docker --version
    exit 0
fi

echo "?“¦ Docker ?¤ì¹˜ ì¤?.."

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
    echo "?”§ Ubuntu/Debian ê³„ì—´ Docker ?¤ì¹˜..."
    
    # ?¨í‚¤ì§€ ?…ë°?´íŠ¸
    sudo apt update
    
    # ?„ìš”???¨í‚¤ì§€ ?¤ì¹˜
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Docker GPG ??ì¶”ê?
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Docker ?€?¥ì†Œ ì¶”ê?
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # ?¨í‚¤ì§€ ?…ë°?´íŠ¸
    sudo apt update
    
    # Docker ?¤ì¹˜
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    echo "?”§ CentOS/RHEL ê³„ì—´ Docker ?¤ì¹˜..."
    
    # EPEL ?€?¥ì†Œ ì¶”ê?
    sudo yum install -y epel-release
    
    # Docker ?€?¥ì†Œ ì¶”ê?
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
    # Docker ?¤ì¹˜
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    
else
    echo "? ï¸ ì§€?ë˜ì§€ ?ŠëŠ” OS: $OS"
    echo "?“‹ ?˜ë™ ?¤ì¹˜ ë°©ë²•:"
    echo "   curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "   sudo sh get-docker.sh"
    exit 1
fi

# Docker ?œë¹„???œì‘
echo "?? Docker ?œë¹„???œì‘..."
sudo systemctl start docker
sudo systemctl enable docker

# ?„ì¬ ?¬ìš©?ë? docker ê·¸ë£¹??ì¶”ê?
echo "?‘¤ ?¬ìš©?ë? docker ê·¸ë£¹??ì¶”ê?..."
sudo usermod -aG docker $USER

# ?¤ì¹˜ ?•ì¸
if command -v docker > /dev/null 2>&1; then
    echo "??Docker ?¤ì¹˜ ?„ë£Œ!"
    docker --version
else
    echo "??Docker ?¤ì¹˜ ?¤íŒ¨"
    exit 1
fi

echo "?§ª Docker ?ŒìŠ¤??.."
sudo docker run hello-world

echo "??Docker ?¤ì¹˜ ë°??ŒìŠ¤???„ë£Œ!"
echo "? ï¸  ì¤‘ìš”: ?ˆë¡œ??ê·¸ë£¹ ê¶Œí•œ???ìš©?˜ë ¤ë©??œìŠ¤?œì„ ?¬ë¡œê·¸ì¸?˜ê±°???¤ìŒ ëª…ë ¹?´ë? ?¤í–‰?˜ì„¸??"
echo "   newgrp docker"
