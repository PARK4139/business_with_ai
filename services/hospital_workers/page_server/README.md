# 병원 근무자 관리 시스템 - 프론트엔드

React + Vite 기반의 프론트엔드 애플리케이션입니다.

## 개발 환경 설정

### 로컬 개발
```bash
cd frontend
npm install
npm run dev
```

### Docker 개발 모드
```bash
# 개발 모드로 전체 시스템 실행
docker-compose -f docker-compose.dev.yml up --build

# 프론트엔드만 실행
docker-compose -f docker-compose.dev.yml up frontend
```

### Docker 운영 모드
```bash
# 운영 모드로 전체 시스템 실행
docker-compose -f docker-compose.prod.yml up --build
```

## 주요 기능

- **Hot Reload**: 개발 모드에서 코드 변경 시 자동 새로고침
- **React Router**: SPA 라우팅
- **Axios**: API 통신
- **ESLint**: 코드 품질 관리

## 접속 방법

- **개발 모드**: http://localhost:5173 (직접 접속) 또는 http://localhost (nginx 프록시)
- **운영 모드**: http://localhost:3000 (직접 접속) 또는 http://localhost (nginx 프록시)

## 프로젝트 구조

```
frontend/
├── src/
│   ├── components/     # 재사용 가능한 컴포넌트
│   ├── pages/         # 페이지 컴포넌트
│   ├── hooks/         # 커스텀 훅
│   ├── utils/         # 유틸리티 함수
│   ├── services/      # API 서비스
│   ├── App.jsx        # 메인 앱 컴포넌트
│   └── main.jsx       # 진입점
├── public/            # 정적 파일
├── Dockerfile.dev     # 개발용 Dockerfile
├── Dockerfile.prod    # 운영용 Dockerfile
└── package.json       # 의존성 관리
```
