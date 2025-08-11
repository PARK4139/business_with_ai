#!/bin/bash

# ?œë¹„??ì¤‘ì? ?¤í¬ë¦½íŠ¸
# ?¬ìš©ë²? ./scripts/ensure_service_shutdowned.sh

set -e

echo "?›‘ ?œë¹„??ì¤‘ì? ?œì‘..."
echo "=================================="

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
echo "?“Š ?„ì¬ ?¤í–‰ ì¤‘ì¸ ?œë¹„???•ì¸..."
if docker compose -f ../services/hospital_workers/docker-compose.yml ps | grep -q "Up"; then
    echo "?” ?¤í–‰ ì¤‘ì¸ ?œë¹„??"
    docker compose -f ../services/hospital_workers/docker-compose.yml ps
    
    echo "=================================="
    echo "?›‘ ?œë¹„??ì¤‘ì? ì¤?.."
    
    # ?œë¹„?¤ë³„ ?œì°¨ ì¤‘ì?
    services=("nginx" "api-service" "auth-service" "redis" "postgres")
    
    for service in "${services[@]}"; do
        echo "?›‘ $service ì¤‘ì? ì¤?.."
        if docker compose -f ../services/hospital_workers/docker-compose.yml stop $service; then
            echo "??$service ì¤‘ì? ?„ë£Œ"
        else
            echo "??$service ì¤‘ì? ?¤íŒ¨"
        fi
        sleep 2
    done
    
    echo "=================================="
    echo "?§¹ ì»¨í…Œ?´ë„ˆ ë°??¤íŠ¸?Œí¬ ?•ë¦¬ ì¤?.."
    
    # ëª¨ë“  ì»¨í…Œ?´ë„ˆ ì¤‘ì? ë°??•ë¦¬
    if docker compose -f ../services/hospital_workers/docker-compose.yml down --remove-orphans; then
        echo "??ëª¨ë“  ?œë¹„??ì¤‘ì? ë°??•ë¦¬ ?„ë£Œ"
    else
        echo "???œë¹„??ì¤‘ì? ?¤íŒ¨"
        exit 1
    fi
    
    echo "=================================="
    echo "?“Š ?•ë¦¬ ???íƒœ ?•ì¸:"
    docker compose -f ../services/hospital_workers/docker-compose.yml ps
    
else
    echo "?¹ï¸ ?¤í–‰ ì¤‘ì¸ ?œë¹„?¤ê? ?†ìŠµ?ˆë‹¤."
fi

echo "=================================="
echo "???œë¹„??ì¤‘ì? ?„ë£Œ!"
echo "?“‹ ì¤‘ì????œë¹„??"
echo "   - nginx (ë¦¬ë²„???„ë¡??"
echo "   - api-service (API ?œë²„)"
echo "   - auth-service (?¸ì¦ ?œë²„)"
echo "   - redis (ìºì‹œ/?¸ì…˜)"
echo "   - postgres (?°ì´?°ë² ?´ìŠ¤)"
echo "=================================="
echo "?’¡ ?œë¹„?¤ë? ?¤ì‹œ ?œì‘?˜ë ¤ë©? ./scripts/ensure_containers_run.sh"
