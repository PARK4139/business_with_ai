# Business with AI

AI 기술을 활용한 비즈니스 솔루션 프로젝트입니다.

## 🏗️ 프로젝트 구조

```
business_with_ai/
├── services/                          # 서비스별 모듈
│   ├── hospital_workers/             # 병원 직원 관리 시스템
│   │   ├── servers/                  # 서버 애플리케이션
│   │   │   ├── api_server/          # FastAPI 백엔드 서버
│   │   │   ├── page_server/         # Next.js 프론트엔드 서버
│   │   │   ├── db_server/           # PostgreSQL 데이터베이스 서버
│   │   │   ├── nginx/               # Nginx 리버스 프록시
│   │   │   └── shared/              # 공통 모듈
│   │   ├── scripts/                  # 유틸리티 스크립트
│   │   ├── tests/                    # 테스트 코드
│   │   ├── prompts/                  # AI 프롬프트 및 템플릿
│   │   ├── logs/                     # 로그 파일
│   │   ├── monitors/                 # 모니터링 도구
│   │   ├── docs/                     # 문서
│   │   ├── fix/                      # 수정 사항
│   │   ├── .venv_windows/           # Windows 가상환경
│   │   ├── .venv_linux/             # Linux 가상환경
│   │   ├── pyproject.toml           # Python 프로젝트 설정
│   │   └── uv.lock                  # 의존성 잠금 파일
│   └── fin_service/                  # 금융 서비스 (개발 예정)
└── README.md                         # 프로젝트 설명서
```

## 🚀 주요 기능

### Hospital Workers Management System
- **프론트엔드**: Next.js 기반 웹 애플리케이션
- **백엔드**: FastAPI 기반 REST API
- **데이터베이스**: PostgreSQL
- **캐시**: Redis
- **프록시**: Nginx
- **테스트**: Selenium 기반 자동화 테스트

### AI Integration
- **프롬프트 엔지니어링**: 체계적인 AI 프롬프트 관리
- **대화형 AI**: 채팅 룸 기반 AI 상호작용
- **자동화**: AI 기반 업무 프로세스 자동화

## 🛠️ 기술 스택

### Backend
- **Python 3.8+**
- **FastAPI**
- **PostgreSQL**
- **Redis**
- **Uvicorn**

### Frontend
- **Next.js 15**
- **TypeScript**
- **Tailwind CSS**
- **React**

### DevOps & Testing
- **Docker & Docker Compose**
- **Selenium WebDriver**
- **Pytest**
- **Nginx**

### AI & ML
- **OpenAI API**
- **LangChain**
- **프롬프트 엔지니어링**

## 📋 요구사항

- **Python**: 3.8 이상
- **Node.js**: 18 이상
- **Docker**: 20.10 이상
- **Docker Compose**: 2.0 이상

## 🚀 빠른 시작

### 1. 저장소 클론
```bash
git clone https://github.com/PARK4139/business_with_ai.git
cd business_with_ai
```

### 2. 서비스 실행 (Hospital Workers)
```bash
cd services/hospital_workers/servers

# 개발 환경 실행
docker compose -f docker-compose.dev.yml up -d

# 또는 프로덕션 환경
docker compose -f docker-compose.prod.yml up -d
```

### 3. 가상환경 설정

#### Windows
```bash
cd services/hospital_workers
.venv_windows\Scripts\activate
uv sync --active
```

#### Linux
```bash
cd services/hospital_workers
source .venv_linux/bin/activate
uv sync --active
```

### 4. 테스트 실행
```bash
cd services/hospital_workers
.venv_windows\Scripts\python.exe tests\test_login_routine_via_selenium_at_windows.py
```

## 🌐 서비스 접속

- **프론트엔드**: http://localhost:5173
- **백엔드 API**: http://localhost:8002
- **데이터베이스**: localhost:5432
- **Redis**: localhost:6379

## 🧪 테스트

### 자동화 테스트
- **Selenium WebDriver**: 브라우저 자동화 테스트
- **의존성 없는 테스트**: 외부 서비스 없이도 테스트 실행 가능
- **OS별 가상환경**: Windows/Linux 환경 자동 감지

### 테스트 실행
```bash
# 전체 테스트
pytest tests/ -v

# 특정 테스트
pytest tests/test_login_routine_via_selenium_at_windows.py -v
```

## 📚 문서

- [비즈니스 제안서](services/hospital_workers/docs/15.BUSINESS_PROPOSAL.md)
- [아키텍처 문서](services/hospital_workers/docs/20.ARCHITECTURE.md)
- [문제 해결 가이드](services/hospital_workers/fix/TROUBLESHOOTING_GUIDE.md)

## 🔧 개발 환경

### Windows
- `.venv_windows/` 가상환경 사용
- Chrome WebDriver (headless 모드 비활성화)

### Linux
- `.venv_linux/` 가상환경 사용
- Chrome WebDriver (headless 모드 활성화)

## 📝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 👥 팀

- **개발자**: PARK4139
- **프로젝트**: Business with AI

## 📞 연락처

- **GitHub**: [@PARK4139](https://github.com/PARK4139)
- **프로젝트 링크**: [https://github.com/PARK4139/business_with_ai](https://github.com/PARK4139/business_with_ai)

---

⭐ 이 프로젝트가 도움이 되었다면 스타를 눌러주세요!
