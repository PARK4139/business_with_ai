# 🏥 병원 근무자 관리 시스템

## 📋 프로젝트 개요

병원 근무자 관리 시스템은 Next.js, FastAPI, PostgreSQL, Redis, Nginx를 활용한 현대적인 웹 애플리케이션입니다.

## 🏗️ 아키텍처

### 서비스 구성
- **Page Server**: Next.js + TypeScript + Tailwind CSS + Zustand + NextAuth.js
- **API Server**: FastAPI (Python)
- **Database Server**: PostgreSQL
- **Cache Server**: Redis
- **Reverse Proxy**: Nginx

### 기술 스택
- **Frontend**: Next.js 15, TypeScript, Tailwind CSS, Zustand, NextAuth.js
- **Backend**: FastAPI, Python
- **Database**: PostgreSQL
- **Cache**: Redis
- **Proxy**: Nginx
- **Container**: Docker & Docker Compose

## 🚀 빠른 시작

### 1. 서비스 운영

#### 대화형 메뉴 사용
```bash
./scripts/ensure_services_operated.sh
```

#### 개별 서비스 실행
```bash
# 전체 서비스 실행
./scripts/ensure_services_operated.sh --all

# 개별 서비스 실행
./scripts/ensure_services_operated.sh --page-server
./scripts/ensure_services_operated.sh --api-server
./scripts/ensure_services_operated.sh --db-server
./scripts/ensure_services_operated.sh --nginx
./scripts/ensure_services_operated.sh --redis
```

### 2. 서비스 모니터링

#### 대화형 메뉴 사용
```bash
./monitors/ensure_service_monitored.sh
```

#### 명령행 옵션 사용
```bash
# 연속 모니터링 (실시간)
./monitors/ensure_service_monitored.sh --continuous

# 요약 모니터링
./monitors/ensure_service_monitored.sh --summary

# 상세 모니터링
./monitors/ensure_service_monitored.sh --detailed
```

## 📊 서비스 운영 메뉴

### 서비스 선택 옵션
1. **Page Server (Next.js)** - 프론트엔드 서버
2. **API Server (FastAPI)** - 백엔드 API 서버
3. **Database Server (PostgreSQL)** - 데이터베이스 서버
4. **Nginx (Reverse Proxy)** - 리버스 프록시
5. **Redis (Cache)** - 캐시 서버
6. **전체 서비스** - 모든 서비스 실행

### 기능
- ✅ 개별 서비스 선택 실행
- ✅ 서비스별 상태 확인
- ✅ 연결 테스트 자동화
- ✅ 컨테이너 빌드 및 실행
- ✅ 오류 처리 및 로깅

## 🔍 서비스 모니터링 메뉴

### 모니터링 옵션
1. **Page Server 모니터링** - 프론트엔드 서버 상태
2. **API Server 모니터링** - 백엔드 API 서버 상태
3. **Database Server 모니터링** - 데이터베이스 서버 상태
4. **Nginx 모니터링** - 리버스 프록시 상태
5. **Redis 모니터링** - 캐시 서버 상태
6. **전체 서비스 모니터링** - 모든 서비스 종합 모니터링
7. **연속 모니터링 (실시간)** - 실시간 모니터링
8. **요약 모니터링** - 간단한 상태 요약

### 모니터링 항목
- 🐳 Docker 서비스 상태
- 📦 컨테이너 상태 및 리소스 사용량
- 🔌 포트 연결 상태
- 🌐 HTTP 연결 테스트
- 🗄️ 데이터베이스 연결 상태
- 🔴 Redis 연결 상태
- 💾 전체 리소스 사용량
- 🌐 서비스 간 네트워크 연결
- 🧪 API 엔드포인트 테스트

## 📁 프로젝트 구조

```
business_with_ai/
├── scripts/
│   ├── ensure_services_operated.sh      # 서비스 운영 스크립트
│   ├── ensure_service_shutdowned.sh     # 서비스 중지 스크립트
│   └── ...
├── monitors/
│   └── ensure_service_monitored.sh      # 서비스 모니터링 스크립트
├── services/
│   └── hospital_workers/
│       ├── page_server/                 # Next.js 프론트엔드
│       ├── api_server/                  # FastAPI 백엔드
│       ├── db_server/                   # PostgreSQL 데이터베이스
│       └── docker-compose.yml          # Docker Compose 설정
├── docs/                               # 문서
├── tests/                              # 테스트
└── logs/                               # 로그
```

## 🛠️ 개발 환경 설정

### 필수 요구사항
- Docker & Docker Compose
- Node.js 18+
- Python 3.8+

### 환경 설정
```bash
# 1. 프로젝트 클론
git clone <repository-url>
cd business_with_ai

# 2. 서비스 실행
./scripts/ensure_services_operated.sh

# 3. 모니터링
./monitors/ensure_service_monitored.sh
```

## 📈 서비스 상태 확인

### 포트 정보
- **Page Server**: http://localhost:5173
- **API Server**: http://localhost:8002
- **Nginx**: http://localhost:80
- **Database**: localhost:5432
- **Redis**: localhost:6379

### API 엔드포인트
- **Health Check**: `GET /health`
- **Location Guide**: `GET /heal_base_hospital_worker/v1/web/ensure/logined/and/hospital-location-guided/{room}`

## 🔧 문제 해결

### 일반적인 문제
1. **Docker 서비스가 실행되지 않음**
   ```bash
   sudo systemctl start docker
   ```

2. **포트 충돌**
   ```bash
   # 사용 중인 포트 확인
   netstat -tuln | grep :80
   ```

3. **컨테이너 실행 실패**
   ```bash
   # 로그 확인
   docker compose -f services/hospital_workers/docker-compose.yml logs
   ```

### 로그 확인
```bash
# 특정 서비스 로그
docker compose -f services/hospital_workers/docker-compose.yml logs page-server

# 전체 로그
docker compose -f services/hospital_workers/docker-compose.yml logs
```

## 📚 추가 문서

- [API 문서](./docs/api.md)
- [배포 가이드](./docs/deployment.md)
- [개발 가이드](./docs/development.md)

## 🤝 기여하기

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

---

**🏥 병원 근무자 관리 시스템** - 현대적이고 효율적인 병원 근무 관리 솔루션



