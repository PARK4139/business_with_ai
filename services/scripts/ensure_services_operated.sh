#!/bin/bash

# 서비스 운영 스크립트 (개선된 버전)
# 사용법: ./scripts/ensure_services_operated.sh [옵션]
# 옵션: --all, --page-server, --api-server, --db-server, --nginx, --redis

set -e

# 프로젝트 루트 디렉토리 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMPOSE_FILE="$PROJECT_ROOT/services/hospital_workers/docker-compose.yml"

# 디버깅을 위한 경로 출력
echo "🔍 스크립트 디렉토리: $SCRIPT_DIR"
echo "🔍 프로젝트 루트: $PROJECT_ROOT"
echo "🔍 Docker Compose 파일: $COMPOSE_FILE"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 서비스 정의
declare -A SERVICES=(
    [1]="page-server"
    [2]="api-server"
    [3]="db-server"
    [4]="nginx"
    [5]="redis"
    [6]="all"
)

# 메뉴 표시 함수
show_menu() {
    echo -e "${CYAN}🏥 병원 근무자 관리 시스템 서비스 운영${NC}"
    echo "=================================="
    echo -e "${YELLOW}📋 서비스 선택:${NC}"
    echo "1. Page Server (Next.js)"
    echo "2. API Server (FastAPI)"
    echo "3. Database Server (PostgreSQL)"
    echo "4. Nginx (Reverse Proxy)"
    echo "5. Redis (Cache)"
    echo "6. 전체 서비스"
    echo "0. 종료"
    echo "=================================="
}

# 서비스 실행 함수
run_service() {
    local service=$1
    local service_name=$2
    
    echo -e "${BLUE}🚀 $service_name 실행 중...${NC}"
    
    case $service in
        "page-server")
            echo "📦 Page Server 빌드 중..."
            docker compose -f "$COMPOSE_FILE" build page-server
            echo "🚀 Page Server 실행 중..."
            docker compose -f "$COMPOSE_FILE" up -d page-server
            ;;
        "api-server")
            echo "📦 API Server 빌드 중..."
            docker compose -f "$COMPOSE_FILE" build api-server
            echo "🚀 API Server 실행 중..."
            docker compose -f "$COMPOSE_FILE" up -d api-server
            ;;
        "db-server")
            echo "📦 Database Server 빌드 중..."
            docker compose -f "$COMPOSE_FILE" build db-server
            echo "🚀 Database Server 실행 중..."
            docker compose -f "$COMPOSE_FILE" up -d db-server
            ;;
        "nginx")
            echo "📦 Nginx 빌드 중..."
            docker compose -f "$COMPOSE_FILE" build nginx
            echo "🚀 Nginx 실행 중..."
            docker compose -f "$COMPOSE_FILE" up -d nginx
            ;;
        "redis")
            echo "📦 Redis 빌드 중..."
            docker compose -f "$COMPOSE_FILE" build redis
            echo "🚀 Redis 실행 중..."
            docker compose -f "$COMPOSE_FILE" up -d redis
            ;;
        "all")
            echo "📦 전체 서비스 빌드 중..."
            docker compose -f "$COMPOSE_FILE" build
            echo "🚀 전체 서비스 실행 중..."
            docker compose -f "$COMPOSE_FILE" up -d
            ;;
    esac
    
    echo -e "${GREEN}✅ $service_name 실행 완료${NC}"
}

# 서비스 상태 확인 함수
check_service_status() {
    local service=$1
    local service_name=$2
    
    echo -e "${CYAN}🔍 $service_name 상태 확인...${NC}"
    
    if docker compose -f "$COMPOSE_FILE" ps | grep -q "$service.*Up"; then
        echo -e "${GREEN}✅ $service_name 실행 중${NC}"
        
        # 컨테이너 상세 정보
        container_id=$(docker compose -f "$COMPOSE_FILE" ps -q $service)
        if [ ! -z "$container_id" ]; then
            echo "   📦 컨테이너 ID: $container_id"
            echo "   📊 상태: $(docker inspect --format='{{.State.Status}}' $container_id)"
            echo "   ⏰ 시작: $(docker inspect --format='{{.State.StartedAt}}' $container_id | cut -d'T' -f1)"
        fi
    else
        echo -e "${RED}❌ $service_name 실행 실패${NC}"
        return 1
    fi
}

# 연결 테스트 함수
test_connection() {
    local service=$1
    local service_name=$2
    
    echo -e "${CYAN}🔌 $service_name 연결 테스트...${NC}"
    
    case $service in
        "page-server")
            if curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 | grep -q "200\|301\|302"; then
                echo -e "${GREEN}✅ Page Server 연결 성공${NC}"
            else
                echo -e "${RED}❌ Page Server 연결 실패${NC}"
            fi
            ;;
        "api-server")
            if curl -s -o /dev/null -w "%{http_code}" http://localhost:8002/health | grep -q "200"; then
                echo -e "${GREEN}✅ API Server 연결 성공${NC}"
            else
                echo -e "${RED}❌ API Server 연결 실패${NC}"
            fi
            ;;
        "nginx")
            if curl -s -o /dev/null -w "%{http_code}" http://localhost:80 | grep -q "200\|301\|302"; then
                echo -e "${GREEN}✅ Nginx 연결 성공${NC}"
            else
                echo -e "${RED}❌ Nginx 연결 실패${NC}"
            fi
            ;;
        "db-server")
            if docker compose -f "$COMPOSE_FILE" exec -T db-server pg_isready -U postgres > /dev/null 2>&1; then
                echo -e "${GREEN}✅ Database 연결 성공${NC}"
            else
                echo -e "${RED}❌ Database 연결 실패${NC}"
            fi
            ;;
        "redis")
            if docker compose -f "$COMPOSE_FILE" exec -T redis redis-cli ping | grep -q "PONG"; then
                echo -e "${GREEN}✅ Redis 연결 성공${NC}"
            else
                echo -e "${RED}❌ Redis 연결 실패${NC}"
            fi
            ;;
    esac
}

# 메인 실행 함수
main() {
    echo -e "${CYAN}🚀 서비스 운영 시작...${NC}"
    echo "=================================="

    # 프로젝트 루트 디렉토리로 이동
    cd "$(dirname "$0")/.."

    # 1. Docker 서비스 상태 확인
    echo -e "${BLUE}🐳 Docker 서비스 상태 확인...${NC}"
    if ! command -v docker > /dev/null 2>&1; then
        echo -e "${RED}❌ Docker가 설치되지 않았습니다.${NC}"
        exit 1
    fi

    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}❌ Docker 데몬이 실행되지 않았습니다.${NC}"
        echo -e "${YELLOW}📋 Docker 서비스 시작: sudo systemctl start docker${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Docker 서비스 정상${NC}"
    echo "=================================="

    # 2. 명령행 인수 처리
    if [ $# -eq 0 ]; then
        # 대화형 메뉴
        while true; do
            show_menu
            echo -e "${YELLOW}선택하세요 (0-6):${NC} "
            read -r choice
            
            case $choice in
                0)
                    echo -e "${GREEN}👋 서비스 운영을 종료합니다.${NC}"
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
                        "전체 서비스"
                    )
                    service_name=${service_names[$((choice-1))]}
                    
                    echo -e "${PURPLE}🎯 선택된 서비스: $service_name${NC}"
                    echo "=================================="
                    
                    # 기존 컨테이너 정리 (선택된 서비스만)
                    echo -e "${YELLOW}🧹 기존 컨테이너 정리...${NC}"
                    if [ "$selected_service" = "all" ]; then
                        docker compose -f "$COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
                    else
                        docker compose -f "$COMPOSE_FILE" stop $selected_service 2>/dev/null || true
                        docker compose -f "$COMPOSE_FILE" rm -f $selected_service 2>/dev/null || true
                    fi
                    
                    # 서비스 실행
                    run_service "$selected_service" "$service_name"
                    
                    # 상태 확인
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
                    echo -e "${GREEN}✅ 서비스 운영 완료!${NC}"
                    echo "=================================="
                    echo -e "${CYAN}💡 모니터링: ./monitors/ensure_service_monitored.sh${NC}"
                    echo -e "${CYAN}💡 서비스 중지: ./scripts/ensure_service_shutdowned.sh${NC}"
                    break
                    ;;
                *)
                    echo -e "${RED}❌ 잘못된 선택입니다. 0-6 중에서 선택하세요.${NC}"
                    ;;
            esac
        done
    else
        # 명령행 인수로 실행
        case $1 in
            --all)
                run_service "all" "전체 서비스"
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
                echo -e "${RED}❌ 잘못된 옵션입니다.${NC}"
                echo "사용법: $0 [--all|--page-server|--api-server|--db-server|--nginx|--redis]"
                exit 1
                ;;
        esac
        
        echo "=================================="
        echo -e "${GREEN}✅ 서비스 운영 완료!${NC}"
        echo "=================================="
    fi
}

# 스크립트 실행
main "$@"


