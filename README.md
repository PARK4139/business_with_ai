### 프로젝트 목적

본 프로젝트는 AI 기반으로 수익실현이 가능한 레벨의 상용 서비스를 기획부터 운영 유지보수를 테스트

## 🚀 최근 업데이트 (2025년 8월 7일)

### ✅ 오늘 완료된 작업들

#### 1. 프로젝트 작업규칙 정립 및 문서화
- **개발 환경 규칙**: uv + pyproject.toml + uv.lock 기반 가상환경 사용
- **서비스 환경**: Linux/Docker + docker-compose 기반 환경 구성
- **서비스 구조**: `services/` 내 디렉토리들이 MSA 서비스별 루트 디렉토리
- **CLI 래퍼**: `pk_ensure` 접두사로 시작하는 파일들은 CLI 모드 실행 시 래퍼 파일

#### 2. 자동 실행 규칙 정립
- **터미널 도구**: 일반 터미널 대신 `run_terminal_cmd` (터미널 실행 자동화 보조 툴) 사용
- **OS 판단**: Linux 명령어와 Windows 명령어를 판단하여 적절한 터미널 선택
- **WSL 환경**: WSL에서는 Linux 명령어를 `run_terminal_cmd`로 실행
- **bash 환경**: zsh가 설치되어 있어도 bash 환경에서 실행 요청

#### 3. 파일 및 디렉토리 관리 규칙
- **문서 관리**: `services/`의 docs는 `docs/README_{MSA_service_name}.md` 형태로 분리 관리
- **레거시 파일**: `deprecated`된 기존 버전 파이썬 파일에는 `# ` 접두사를 붙여서 rename

#### 4. 코드 작성 규칙 정립
- **다국어 지원**: 모든 프로그램은 다국어 지원 가능하도록 작성 (PkMessage2025 객체 적극 활용)
- **이모지 제외**: 코드 작성 시 이모지 사용 금지
- **함수명 규칙**: 함수명은 `ensure_` 접두사로 시작
- **파일명 규칙**: `.py`, `.sh`, `.cmd`, `.bat`, `.ps1` 확장자 파일들은 `ensure_` 접두사로 시작

#### 5. 테스트 코드 규칙
- **테스트 파일**: `test_` 접두사를 붙여 명시적으로 작성
- **테스트 위치**: `tests` 폴더에서 작성

#### 6. 경로 처리 규칙
- **Path 객체 활용**: 파이썬에서 파일 및 디렉토리 경로 처리 시 Path 객체 사용
- **레거시 변환**: str path 사용 시 Path 객체로 변환 (예: `D_PKG_WINDOWS` → `Path(D_PKG_WINDOWS)`)
- **경로 유틸리티**: `pkg_py/system_object/files.py`, `pkg_py/system_object/directories.py` 활용

#### 7. 코드 구조 규칙
- **클래스 작성**: `pkg_py/system_object`에 작성
- **함수 작성**: `pkg_py/function_split`에 작성
- **래퍼 패턴**: pkg_py에 래퍼 작성 시 주변 래퍼의 패턴을 비교하여 재생성

#### 8. 보안 규칙
- **민감정보 경고**: 비밀번호, API 키 등 민감한 개인정보가 포함된 컨텐츠에 대해 경고 요청

#### 9. 프론트엔드 개발 환경 구축
- **React + Vite 기반 프론트엔드**: Hot Reload 지원 개발 환경
- **개발모드/운영모드 구분**: 
  - `Dockerfile.dev`: 개발모드용 (hot reload 지원)
  - `Dockerfile.prod`: 운영모드용 (정적 파일 빌드)
- **프론트엔드 서비스 구성**:
  - ✅ React + Vite 개발 환경
  - ✅ Hot Reload 기능 (코드 변경 시 자동 새로고침)
  - ✅ nginx 프록시 연동
  - ✅ Docker 컨테이너화 완료

#### 10. 프론트엔드 접속 환경
- **직접 접근**: `http://localhost:5173`
- **nginx 프록시**: `http://localhost`
- **개발 환경**: bash 환경에서 실행
- **Hot Reload 테스트**: 파일 수정 시 자동 반영 확인

#### 11. 스크립트 네이밍 컨벤션 개선
- **파일명 변경**: `ensure_docker_*` → `ensure_containers_*`
- **내용 패턴 변경**: 모든 스크립트 내 `ensure_docker_` → `ensure_containers_`
- **변경된 파일들**:
  - `ensure_containers_install.sh`
  - `ensure_containers_compose_install.sh`
  - `ensure_containers_build.sh`
  - `ensure_containers_run.sh`
  - `ensure_containers_stop.sh`

#### 12. 서비스 운영 환경 검증 및 테스트
- **Docker 서비스 상태 확인**: 모든 컨테이너 정상 실행 확인
- **API 테스트 완료**: 13개 엔드포인트 모두 성공 (100% 성공률)
- **서비스 구성 요소 검증**:
  - ✅ Nginx 리버스 프록시 (포트 80)
  - ✅ Auth Service (포트 8001)
  - ✅ API Service (포트 8002)
  - ✅ **Frontend Service (포트 5173)** (새로 추가)
  - ✅ PostgreSQL 데이터베이스 (포트 5432)
  - ✅ Redis 캐시 (포트 6379)

#### 13. API 엔드포인트 테스트 결과
- **인증 관련 API**:
  - ✅ POST /heal_base_hospital_worker/v1/api/ensure/login/
  - ✅ GET /heal_base_hospital_worker/v1/api/ensure/user/profile/
- **병원 정보 API**:
  - ✅ GET /heal_base_hospital_worker/v1/api/ensure/hospital/locations/
  - ✅ GET /heal_base_hospital_worker/v1/api/ensure/hospital/location/101
- **웹 인터페이스 API**:
  - ✅ 로그인 페이지 및 가이드
  - ✅ 회원가입 페이지
  - ✅ Google OAuth 연동 페이지
  - ✅ 위치 가이드 페이지

#### 14. 개발 환경 최적화
- **Bash 환경 전환**: zsh에서 bash로 개발 환경 통일
- **Docker 권한 설정**: sudo 권한으로 Docker 명령어 실행 환경 구성
- **서비스 모니터링**: 실시간 컨테이너 상태 확인 및 로그 분석

### ✅ 이전 완료된 작업들

#### 1. MSA 아키텍처 구축
- **DDD + MSA + Docker** 기반 서비스 구조 설계
- **로그인 서버** (`auth-service`) - 사용자 인증 전담
- **API 서버** (`api-service`) - 비즈니스 로직 처리
- **Nginx** - 리버스 프록시
- **PostgreSQL** - 데이터베이스
- **Redis** - 캐시/세션

#### 2. 자동화 스크립트 개발
- `scripts/ensure_containers_install.sh` - Docker 설치 자동화
- `scripts/ensure_containers_compose_install.sh` - Docker Compose 설치 자동화
- `scripts/ensure_containers_build.sh` - 컨테이너 빌드 자동화
- `scripts/ensure_containers_run.sh` - 컨테이너 실행 자동화
- `scripts/ensure_containers_stop.sh` - 컨테이너 중지 자동화
- `scripts/ensure_service_test.sh` - 서비스 빌드 테스트
- `scripts/ensure_service_operated.sh` - 서비스 운영 테스트

#### 3. FastAPI 서비스 구현
- **인증 서비스**: 로그인/회원가입 API
- **비즈니스 로직 서비스**: 메인 페이지, 위치 가이드 API
- **API 엔드포인트**:
  - `POST /api/heal_base_hospital_worker/v1/ensure/login/`
  - `POST /api/heal_base_hospital_worker/v1/ensure/signup/`
  - `GET /api/heal_base_hospital_worker/v1/ensure/main/`
  - `GET /api/heal_base_hospital_worker/v1/ensure/main/location/{실}`

#### 4. 테스트 결과
- ✅ Docker 서비스 정상
- ✅ 컨테이너 빌드 성공
- ✅ 컨테이너 실행 성공
- ✅ HTTP 연결 성공
- ✅ 데이터베이스 연결 성공
- ✅ Redis 연결 성공
- ✅ API 테스트 성공

### 🏗️ 기술 스택
- **아키텍처**: DDD + MSA
- **API 프레임워크**: FastAPI (Python 3.13+)
- **프론트엔드**: Next.js (React)
- **데이터베이스**: PostgreSQL
- **캐시**: Redis
- **리버스 프록시**: Nginx
- **개발 환경**: Bash, uv (Python 패키지 관리)
- **배포**: AWS EC2 (API/DB), Vercel (Frontend)

### 📂 프로젝트 구조
```
business_with_ai/
├── services/hospital_workers/     # MSA 서비스들
│   ├── page_server/              # Next.js 프론트엔드 서비스
│   ├── api_server/               # FastAPI 백엔드 서비스
│   ├── db_server/                # PostgreSQL 데이터베이스 서비스
│   ├── shared/                   # 공통 모듈
│   ├── nginx/                    # 리버스 프록시
│   └── docker-compose.yml        # Docker 구성
├── scripts/                      # 자동화 스크립트들 (ensure_ prefix)
├── tests/                        # 테스트 스크립트들 (test_ prefix)
├── prompts/                      # AI 기반 코드생성 프롬프트 모음
├── business_documents/           # 비즈니스 기획서
└── logs/                         # 로그 파일들
```

### 🚀 사용 방법
```bash
# Docker 설치 (필요시)
./scripts/ensure_containers_install.sh

# Docker Compose 설치 (필요시)
./scripts/ensure_containers_compose_install.sh

# 서비스 빌드
./scripts/ensure_containers_build.sh

# 서비스 실행
./scripts/ensure_containers_run.sh

# 서비스 운영 테스트
./scripts/ensure_service_operated.sh

# API 테스트
python3 scripts/all_api_test.py

# 서비스 중지
./scripts/ensure_containers_stop.sh
```

### 📊 현재 서비스 상태
- **전체 API 엔드포인트**: 13개
- **테스트 성공률**: 100%
- **서비스 가동 시간**: 24/7 운영 준비 완료
- **다음 단계**: 프론트엔드 개발 또는 추가 기능 구현



