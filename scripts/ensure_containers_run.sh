#!/bin/bash

# Docker ì»¨í…Œ?´ë„ˆ ?¤í–‰ ?ë™???¤í¬ë¦½íŠ¸
# ?¬ìš©ë²? ./scripts/ensure_containers_run.sh [dev|prod]

set -e

# ?˜ê²½ ?¤ì • (ê¸°ë³¸ê°? dev)
ENVIRONMENT=${1:-dev}

echo "?? Docker ì»¨í…Œ?´ë„ˆ ?¤í–‰ ?œì‘... (?˜ê²½: $ENVIRONMENT)"

# ?„ë¡œ?íŠ¸ ë£¨íŠ¸ ?”ë ‰? ë¦¬ë¡??´ë™
cd "$(dirname "$0")/.."

# ?œë¹„???”ë ‰? ë¦¬ ?•ì¸
if [ ! -d "../services/hospital_workers" ]; then
    echo "??../services/hospital_workers ?”ë ‰? ë¦¬ë¥?ì°¾ì„ ???†ìŠµ?ˆë‹¤."
    exit 1
fi

# ?˜ê²½ë³?Docker Compose ?Œì¼ ?•ì¸
if [ "$ENVIRONMENT" = "prod" ]; then
    COMPOSE_FILE="../services/hospital_workers/docker-compose.prod.yml"
    echo "?”§ ?„ë¡œ?•ì…˜ ?˜ê²½ ?¤í–‰"
else
    COMPOSE_FILE="../services/hospital_workers/docker-compose.dev.yml"
    echo "?”§ ê°œë°œ ?˜ê²½ ?¤í–‰"
fi

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "??$COMPOSE_FILE ?Œì¼??ì°¾ì„ ???†ìŠµ?ˆë‹¤."
    exit 1
fi

# ê¸°ì¡´ ì»¨í…Œ?´ë„ˆ ì¤‘ì?
echo "?›‘ ê¸°ì¡´ ì»¨í…Œ?´ë„ˆ ì¤‘ì? ì¤?.."
sudo docker compose -f "$COMPOSE_FILE" down

# ì»¨í…Œ?´ë„ˆ ?¤í–‰
echo "?¶ï¸ Docker ì»¨í…Œ?´ë„ˆ ?¤í–‰ ì¤?.."
sudo docker compose -f "$COMPOSE_FILE" up -d

# ?œë¹„???íƒœ ?•ì¸
echo "?“Š ?œë¹„???íƒœ ?•ì¸ ì¤?.."
sleep 10

# ê°??œë¹„???íƒœ ?•ì¸
services=("auth-service" "api-service" "frontend" "nginx" "user-db" "redis")
for service in "${services[@]}"; do
    if sudo docker compose -f "$COMPOSE_FILE" ps | grep -q "$service.*Up"; then
        echo "??$service ?¤í–‰ ì¤?
    else
        echo "??$service ?¤í–‰ ?¤íŒ¨"
    fi
done

echo "??Docker ì»¨í…Œ?´ë„ˆ ?¤í–‰ ?„ë£Œ! (?˜ê²½: $ENVIRONMENT)"
echo "?Œ ?œë¹„???‘ì† ?•ë³´:"
echo "   - ë©”ì¸ ?œë¹„?? http://localhost"
echo "   - ?„ë¡ ?¸ì—”??(ì§ì ‘): http://localhost:5173"
echo "   - ?¸ì¦ ?œë¹„?? http://localhost:8001"
echo "   - API ?œë¹„?? http://localhost:8002"
echo "   - ?°ì´?°ë² ?´ìŠ¤: localhost:5432"
echo "   - Redis: localhost:6379"

if [ "$ENVIRONMENT" = "dev" ]; then
    echo ""
    echo "?’¡ ê°œë°œ ëª¨ë“œ ?¹ì§•:"
    echo "   - ì½”ë“œ ë³€ê²½ì‚¬??ì¦‰ì‹œ ë°˜ì˜"
    echo "   - ë³¼ë¥¨ ë§ˆìš´?¸ë¡œ ë¹ ë¥¸ ê°œë°œ"
    echo "   - --reload ?µì…˜?¼ë¡œ ?ë™ ?¬ì‹œ??
    echo "   - ?„ë¡ ?¸ì—”??Hot Reload ì§€??
    echo "   - React + Vite ê°œë°œ ?˜ê²½"
fi
