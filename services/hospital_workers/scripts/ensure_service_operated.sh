#!/bin/bash
set -e

echo "?? ?œë¹„???´ì˜ ?œì‘..."
echo "=================================="

# ?„ë¡œ?íŠ¸ ë£¨íŠ¸ ?”ë ‰? ë¦¬ë¡??´ë™
cd "$(dirname "$0")/.."

# 1. Docker ?œë¹„???íƒœ ?•ì¸
echo "?³ Docker ?œë¹„???íƒœ ?•ì¸..."
if ! command -v docker > /dev/null 2>&1; then
    echo "??Dockerê°€ ?¤ì¹˜?˜ì? ?Šì•˜?µë‹ˆ??"
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    echo "??Docker ?°ëª¬???¤í–‰?˜ì? ?Šì•˜?µë‹ˆ??"
    echo "?“‹ Docker ?œë¹„???œì‘: sudo systemctl start docker"
    exit 1
fi

echo "??Docker ?œë¹„???•ìƒ"
echo "=================================="

# 2. ì»¨í…Œ?´ë„ˆ ë¹Œë“œ ë°??¤í–‰
echo "?”¨ ì»¨í…Œ?´ë„ˆ ë¹Œë“œ ë°??¤í–‰..."
if [ ! -f "../services/hospital_workers/docker-compose.yml" ]; then
    echo "??docker-compose.yml ?Œì¼??ì°¾ì„ ???†ìŠµ?ˆë‹¤."
    exit 1
fi

# ê¸°ì¡´ ì»¨í…Œ?´ë„ˆ ?•ë¦¬
echo "?§¹ ê¸°ì¡´ ì»¨í…Œ?´ë„ˆ ?•ë¦¬..."
docker compose -f ../services/hospital_workers/docker-compose.yml down --remove-orphans 2>/dev/null || true

# ?´ë?ì§€ ë¹Œë“œ
echo "?“¦ ?´ë?ì§€ ë¹Œë“œ ì¤?.."
if docker compose -f ../services/hospital_workers/docker-compose.yml build; then
    echo "???´ë?ì§€ ë¹Œë“œ ?±ê³µ"
else
    echo "???´ë?ì§€ ë¹Œë“œ ?¤íŒ¨"
    exit 1
fi

# ì»¨í…Œ?´ë„ˆ ?¤í–‰
echo "?? ì»¨í…Œ?´ë„ˆ ?¤í–‰ ì¤?.."
if docker compose -f ../services/hospital_workers/docker-compose.yml up -d; then
    echo "??ì»¨í…Œ?´ë„ˆ ?¤í–‰ ?±ê³µ"
else
    echo "??ì»¨í…Œ?´ë„ˆ ?¤í–‰ ?¤íŒ¨"
    exit 1
fi
echo "=================================="

# 3. ?œë¹„???íƒœ ?•ì¸
echo "?“Š ?œë¹„???íƒœ ?•ì¸..."
echo "???œë¹„???œì‘ ?€ê¸?ì¤?.. (10ì´?"
sleep 10

services=("page-server" "api-server" "db-server" "nginx" "redis")
all_running=true

echo "?” ê°??œë¹„???íƒœ:"
for service in "${services[@]}"; do
    if docker compose -f ../services/hospital_workers/docker-compose.yml ps | grep -q "$service.*Up"; then
        echo "??$service ?¤í–‰ ì¤?
    else
        echo "??$service ?¤í–‰ ?¤íŒ¨"
        all_running=false
    fi
done

if [ "$all_running" = false ]; then
    echo "???¼ë? ?œë¹„???¤í–‰ ?¤íŒ¨"
    exit 1
fi
echo "=================================="

# 4. ê¸°ë³¸ ?°ê²° ?•ì¸
echo "?”Œ ê¸°ë³¸ ?°ê²° ?•ì¸..."
sleep 5

# API Service ?°ê²° ?•ì¸
echo "?“‹ API Service (?¬íŠ¸ 8002):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8002/health | grep -q "200"; then
    echo "??API Service ?°ê²° ?±ê³µ"
else
    echo "??API Service ?°ê²° ?¤íŒ¨"
fi

# Nginx ?°ê²° ?•ì¸
echo "?“‹ Nginx (?¬íŠ¸ 80):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:80 | grep -q "200\|301\|302"; then
    echo "??Nginx ?°ê²° ?±ê³µ"
else
    echo "??Nginx ?°ê²° ?¤íŒ¨"
fi
echo "=================================="

echo "???œë¹„???´ì˜ ?„ë£Œ!"
echo "=================================="
echo "?“‹ ?´ì˜ ê²°ê³¼ ?”ì•½:"
echo "   - Docker ?œë¹„?? ?•ìƒ"
echo "   - ì»¨í…Œ?´ë„ˆ ë¹Œë“œ: ?±ê³µ"
echo "   - ì»¨í…Œ?´ë„ˆ ?¤í–‰: ?±ê³µ"
echo "   - ?œë¹„???íƒœ: ?•ìƒ"
echo "   - ê¸°ë³¸ ?°ê²°: ?•ì¸??
echo "=================================="
echo "?’¡ ?œë¹„?¤ë? ì¤‘ì??˜ë ¤ë©? ./scripts/ensure_service_shutdowned.sh"
echo "?’¡ ëª¨ë‹ˆ?°ë§?˜ë ¤ë©? ./monitors/ensure_service_monitored.sh"
