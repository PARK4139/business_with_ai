#!/bin/bash

# Docker ì»¨í…Œ?´ë„ˆ ë¹Œë“œ ?ë™???¤í¬ë¦½íŠ¸
# ?¬ìš©ë²? ./scripts/ensure_containers_build.sh [dev|prod]

set -e

# ?˜ê²½ ?¤ì • (ê¸°ë³¸ê°? dev)
ENVIRONMENT=${1:-dev}

echo "?—ï¸?Docker ì»¨í…Œ?´ë„ˆ ë¹Œë“œ ?œì‘... (?˜ê²½: $ENVIRONMENT)"

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
    echo "?”§ ?„ë¡œ?•ì…˜ ?˜ê²½ ë¹Œë“œ"
else
    COMPOSE_FILE="../services/hospital_workers/docker-compose.dev.yml"
    echo "?”§ ê°œë°œ ?˜ê²½ ë¹Œë“œ"
fi

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "??$COMPOSE_FILE ?Œì¼??ì°¾ì„ ???†ìŠµ?ˆë‹¤."
    exit 1
fi

# ê¸°ì¡´ ì»¨í…Œ?´ë„ˆ ?•ë¦¬
echo "?§¹ ê¸°ì¡´ ì»¨í…Œ?´ë„ˆ ?•ë¦¬ ì¤?.."
docker compose -f "$COMPOSE_FILE" down --remove-orphans

# ?´ë?ì§€ ë¹Œë“œ
echo "?”¨ Docker ?´ë?ì§€ ë¹Œë“œ ì¤?.."
docker compose -f "$COMPOSE_FILE" build --no-cache

echo "??Docker ì»¨í…Œ?´ë„ˆ ë¹Œë“œ ?„ë£Œ! (?˜ê²½: $ENVIRONMENT)"
echo "?“‹ ë¹Œë“œ???œë¹„??"
echo "   - auth-service (ë¡œê·¸???œë²„)"
echo "   - api-service (API ?œë²„)"
echo "   - user-db (?¬ìš©???°ì´?°ë² ?´ìŠ¤)"
echo "   - nginx (ë¦¬ë²„???„ë¡??"
echo "   - redis (ìºì‹œ/?¸ì…˜)"
echo ""
echo "?’¡ ?¤í–‰ ëª…ë ¹??"
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "   docker compose -f $COMPOSE_FILE up -d"
else
    echo "   docker compose -f $COMPOSE_FILE up -d"
fi
