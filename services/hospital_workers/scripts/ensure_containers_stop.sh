#!/bin/bash

# Docker ì»¨í…Œ?´ë„ˆ ì¤‘ì? ?ë™???¤í¬ë¦½íŠ¸
# ?¬ìš©ë²? ./scripts/ensure_containers_stop.sh

set -e

echo "?›‘ Docker ì»¨í…Œ?´ë„ˆ ì¤‘ì? ?œì‘..."

# ?„ë¡œ?íŠ¸ ë£¨íŠ¸ ?”ë ‰? ë¦¬ë¡??´ë™
cd "$(dirname "$0")/.."

# ?œë¹„???”ë ‰? ë¦¬ ?•ì¸
if [ ! -d "../services/hospital_workers" ]; then
    echo "??../services/hospital_workers ?”ë ‰? ë¦¬ë¥?ì°¾ì„ ???†ìŠµ?ˆë‹¤."
    exit 1
fi

# Docker Compose ?Œì¼ ?•ì¸
if [ ! -f "../services/hospital_workers/docker-compose.yml" ]; then
    echo "??docker-compose.yml ?Œì¼??ì°¾ì„ ???†ìŠµ?ˆë‹¤."
    exit 1
fi

# ?¤í–‰ ì¤‘ì¸ ì»¨í…Œ?´ë„ˆ ?•ì¸
if docker compose -f ../services/hospital_workers/docker-compose.yml ps | grep -q "Up"; then
    echo "?›‘ ?¤í–‰ ì¤‘ì¸ ì»¨í…Œ?´ë„ˆ ì¤‘ì? ì¤?.."
    docker compose -f ../services/hospital_workers/docker-compose.yml down
    
    echo "?§¹ ì»¨í…Œ?´ë„ˆ ë°??¤íŠ¸?Œí¬ ?•ë¦¬ ì¤?.."
    docker compose -f ../services/hospital_workers/docker-compose.yml down --remove-orphans
    
    echo "??Docker ì»¨í…Œ?´ë„ˆ ì¤‘ì? ?„ë£Œ!"
else
    echo "?¹ï¸ ?¤í–‰ ì¤‘ì¸ ì»¨í…Œ?´ë„ˆê°€ ?†ìŠµ?ˆë‹¤."
fi

# ?•ë¦¬???íƒœ ?•ì¸
echo "?“Š ?•ë¦¬ ?íƒœ ?•ì¸:"
docker compose -f ../services/hospital_workers/docker-compose.yml ps
