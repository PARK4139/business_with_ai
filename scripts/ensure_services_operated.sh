#!/bin/bash

# ?�비???�영 ?�크립트 (개선??버전)
# ?�용�? ./scripts/ensure_services_operated.sh [?�션]
# ?�션: --all, --page-server, --api-server, --db-server, --nginx, --redis

set -e

# ?�로?�트 루트 ?�렉?�리 ?�정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMPOSE_FILE="$PROJECT_ROOT/services/hospital_workers/docker-compose.yml"

# ?�버깅을 ?�한 경로 출력
echo "?�� ?�크립트 ?�렉?�리: $SCRIPT_DIR"
echo "?�� ?�로?�트 루트: $PROJECT_ROOT"
echo "?�� Docker Compose ?�일: $COMPOSE_FILE"

# ?�상 ?�의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ?�비???�의
declare -A SERVICES=(
    [1]="page-server"
    [2]="api-server"
    [3]="db-server"
    [4]="nginx"
    [5]="redis"
    [6]="all"
)

# 메뉴 ?�시 ?�수
show_menu() {
    echo -e "${CYAN}?�� 병원 근무??관�??�스???�비???�영${NC}"
    echo "=================================="
    echo -e "${YELLOW}?�� ?�비???�택:${NC}"
    echo "1. Page Server (Next.js)"
    echo "2. API Server (FastAPI)"
    echo "3. Database Server (PostgreSQL)"
    echo "4. Nginx (Reverse Proxy)"
    echo "5. Redis (Cache)"
    echo "6. ?�체 ?�비??
    echo "0. 종료"
    echo "=================================="
}

# ?�비???�행 ?�수
run_service() {
    local service=$1
    local service_name=$2
    
    echo -e "${BLUE}?? $service_name ?�행 �?..${NC}"
    
    case $service in
        "page-server")
            echo "?�� Page Server 빌드 �?.."
            docker compose -f "$COMPOSE_FILE" build page-server
            echo "?? Page Server ?�행 �?.."
            docker compose -f "$COMPOSE_FILE" up -d page-server
            ;;
        "api-server")
            echo "?�� API Server 빌드 �?.."
            docker compose -f "$COMPOSE_FILE" build api-server
            echo "?? API Server ?�행 �?.."
            docker compose -f "$COMPOSE_FILE" up -d api-server
            ;;
        "db-server")
            echo "?�� Database Server 빌드 �?.."
            docker compose -f "$COMPOSE_FILE" build db-server
            echo "?? Database Server ?�행 �?.."
            docker compose -f "$COMPOSE_FILE" up -d db-server
            ;;
        "nginx")
            echo "?�� Nginx 빌드 �?.."
            docker compose -f "$COMPOSE_FILE" build nginx
            echo "?? Nginx ?�행 �?.."
            docker compose -f "$COMPOSE_FILE" up -d nginx
            ;;
        "redis")
            echo "?�� Redis 빌드 �?.."
            docker compose -f "$COMPOSE_FILE" build redis
            echo "?? Redis ?�행 �?.."
            docker compose -f "$COMPOSE_FILE" up -d redis
            ;;
        "all")
            echo "?�� ?�체 ?�비??빌드 �?.."
            docker compose -f "$COMPOSE_FILE" build
            echo "?? ?�체 ?�비???�행 �?.."
            docker compose -f "$COMPOSE_FILE" up -d
            ;;
    esac
    
    echo -e "${GREEN}??$service_name ?�행 ?�료${NC}"
}

# ?�비???�태 ?�인 ?�수
check_service_status() {
    local service=$1
    local service_name=$2
    
    echo -e "${CYAN}?�� $service_name ?�태 ?�인...${NC}"
    
    if docker compose -f "$COMPOSE_FILE" ps | grep -q "$service.*Up"; then
        echo -e "${GREEN}??$service_name ?�행 �?{NC}"
        
        # 컨테?�너 ?�세 ?�보
        container_id=$(docker compose -f "$COMPOSE_FILE" ps -q $service)
        if [ ! -z "$container_id" ]; then
            echo "   ?�� 컨테?�너 ID: $container_id"
            echo "   ?�� ?�태: $(docker inspect --format='{{.State.Status}}' $container_id)"
            echo "   ???�작: $(docker inspect --format='{{.State.StartedAt}}' $container_id | cut -d'T' -f1)"
        fi
    else
        echo -e "${RED}??$service_name ?�행 ?�패${NC}"
        return 1
    fi
}

# ?�결 ?�스???�수
test_connection() {
    local service=$1
    local service_name=$2
    
    echo -e "${CYAN}?�� $service_name ?�결 ?�스??..${NC}"
    
    case $service in
        "page-server")
            if curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 | grep -q "200\|301\|302"; then
                echo -e "${GREEN}??Page Server ?�결 ?�공${NC}"
            else
                echo -e "${RED}??Page Server ?�결 ?�패${NC}"
            fi
            ;;
        "api-server")
            if curl -s -o /dev/null -w "%{http_code}" http://localhost:8002/health | grep -q "200"; then
                echo -e "${GREEN}??API Server ?�결 ?�공${NC}"
            else
                echo -e "${RED}??API Server ?�결 ?�패${NC}"
            fi
            ;;
        "nginx")
            if curl -s -o /dev/null -w "%{http_code}" http://localhost:80 | grep -q "200\|301\|302"; then
                echo -e "${GREEN}??Nginx ?�결 ?�공${NC}"
            else
                echo -e "${RED}??Nginx ?�결 ?�패${NC}"
            fi
            ;;
        "db-server")
            if docker compose -f "$COMPOSE_FILE" exec -T db-server pg_isready -U postgres > /dev/null 2>&1; then
                echo -e "${GREEN}??Database ?�결 ?�공${NC}"
            else
                echo -e "${RED}??Database ?�결 ?�패${NC}"
            fi
            ;;
        "redis")
            if docker compose -f "$COMPOSE_FILE" exec -T redis redis-cli ping | grep -q "PONG"; then
                echo -e "${GREEN}??Redis ?�결 ?�공${NC}"
            else
                echo -e "${RED}??Redis ?�결 ?�패${NC}"
            fi
            ;;
    esac
}

# 메인 ?�행 ?�수
main() {
    echo -e "${CYAN}?? ?�비???�영 ?�작...${NC}"
    echo "=================================="

    # ?�로?�트 루트 ?�렉?�리�??�동
    cd "$(dirname "$0")/.."

    # 1. Docker ?�비???�태 ?�인
    echo -e "${BLUE}?�� Docker ?�비???�태 ?�인...${NC}"
    if ! command -v docker > /dev/null 2>&1; then
        echo -e "${RED}??Docker가 ?�치?��? ?�았?�니??${NC}"
        exit 1
    fi

    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}??Docker ?�몬???�행?��? ?�았?�니??${NC}"
        echo -e "${YELLOW}?�� Docker ?�비???�작: sudo systemctl start docker${NC}"
        exit 1
    fi

    echo -e "${GREEN}??Docker ?�비???�상${NC}"
    echo "=================================="

    # 2. 명령???�수 처리
    if [ $# -eq 0 ]; then
        # ?�?�형 메뉴
        while true; do
            show_menu
            echo -e "${YELLOW}?�택?�세??(0-6):${NC} "
            read -r choice
            
            case $choice in
                0)
                    echo -e "${GREEN}?�� ?�비???�영??종료?�니??${NC}"
                    exit 0
                    ;;
                1|2|3|4|5|6)
                    selected_service=${SERVICES[$choice]}
                    service_names=(
                        "Page Server (Next.js)"
                        "API Server (FastAPI)"
                        "Database Server (PostgreSQL)"
                        "Nginx (Reverse Proxy)"
                        "Redis (Cache)"
                        "?�체 ?�비??
                    )
                    service_name=${service_names[$((choice-1))]}
                    
                    echo -e "${PURPLE}?�� ?�택???�비?? $service_name${NC}"
                    echo "=================================="
                    
                    # 기존 컨테?�너 ?�리 (?�택???�비?�만)
                    echo -e "${YELLOW}?�� 기존 컨테?�너 ?�리...${NC}"
                    if [ "$selected_service" = "all" ]; then
                        docker compose -f "$COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
                    else
                        docker compose -f "$COMPOSE_FILE" stop $selected_service 2>/dev/null || true
                        docker compose -f "$COMPOSE_FILE" rm -f $selected_service 2>/dev/null || true
                    fi
                    
                    # ?�비???�행
                    run_service "$selected_service" "$service_name"
                    
                    # ?�태 ?�인
                    if [ "$selected_service" = "all" ]; then
                        for service in "${SERVICES[@]}"; do
                            if [ "$service" != "all" ]; then
                                check_service_status "$service" "$service"
                                test_connection "$service" "$service"
                            fi
                        done
                    else
                        check_service_status "$selected_service" "$selected_service"
                        test_connection "$selected_service" "$selected_service"
                    fi
                    
                    echo "=================================="
                    echo -e "${GREEN}???�비???�영 ?�료!${NC}"
                    echo "=================================="
                    echo -e "${CYAN}?�� 모니?�링: ./monitors/ensure_service_monitored.sh${NC}"
                    echo -e "${CYAN}?�� ?�비??중�?: ./scripts/ensure_service_shutdowned.sh${NC}"
                    break
                    ;;
                *)
                    echo -e "${RED}???�못???�택?�니?? 0-6 중에???�택?�세??${NC}"
                    ;;
            esac
        done
    else
        # 명령???�수�??�행
        case $1 in
            --all)
                run_service "all" "?�체 ?�비??
                ;;
            --page-server)
                run_service "page-server" "Page Server"
                ;;
            --api-server)
                run_service "api-server" "API Server"
                ;;
            --db-server)
                run_service "db-server" "Database Server"
                ;;
            --nginx)
                run_service "nginx" "Nginx"
                ;;
            --redis)
                run_service "redis" "Redis"
                ;;
            *)
                echo -e "${RED}???�못???�션?�니??${NC}"
                echo "?�용�? $0 [--all|--page-server|--api-server|--db-server|--nginx|--redis]"
                exit 1
                ;;
        esac
        
        echo "=================================="
        echo -e "${GREEN}???�비???�영 ?�료!${NC}"
        echo "=================================="
    fi
}

# ?�크립트 ?�행
main "$@"


