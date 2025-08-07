# Cursor Chatting Room 작업규칙 및 사용 가이드

## 📋 작업규칙 (항시 적용 필수)

### 🔧 개발 환경 규칙
- **파이썬 환경**: uv + pyproject.toml + uv.lock 기반 가상환경 사용
- **서비스 환경**: Linux/Docker + docker-compose 기반 환경 구성
- **서비스 구조**: `pk_system/services/` 내 `service_` 접두사로 시작하는 디렉토리들이 MSA 서비스별 루트 디렉토리
- **CLI 래퍼**: `pk_ensure` 접두사로 시작하는 파일들은 pk_system의 CLI 모드 실행 시 래퍼 파일

### 🚀 자동 실행/테스트 규칙
- **터미널 도구**: 일반 터미널 대신 `run_terminal_cmd` (터미널 실행 자동화 보조 툴) 사용
- **OS 판단**: Linux 명령어와 Windows 명령어를 판단하여 적절한 터미널 선택
- **WSL 환경**: WSL에서는 Linux 명령어를 `run_terminal_cmd`로 실행

### 📁 파일 및 디렉토리 관리 규칙
- **문서 관리**: `pk_system/services/`의 docs는 `pk_system/docs/README_{MSA_service_name}.md` 형태로 분리 관리
- **레거시 파일**: 기존 버전 파이썬 파일에는 `# ` 접두사를 붙여서 rename

### 💻 코드 작성 규칙
- **다국어 지원**: 모든 프로그램은 다국어 지원 가능하도록 작성 (PkMessage2025 객체 적극 활용)
- **이모지 제외**: 코드 작성 시 이모지 사용 금지
- **함수명 규칙**: 함수명은 `ensure_` 접두사로 시작
- **파일명 규칙**: `.py`, `.sh`, `.cmd`, `.bat`, `.ps1` 확장자 파일들은 `ensure_` 접두사로 시작

### 🧪 테스트 코드 규칙
- **테스트 파일**: `test_` 접두사를 붙여 명시적으로 작성
- **테스트 위치**: `tests` 폴더에서 작성

### 📂 경로 처리 규칙
- **Path 객체 활용**: 파이썬에서 파일 및 디렉토리 경로 처리 시 Path 객체 사용
- **레거시 변환**: str path 사용 시 Path 객체로 변환 (예: `D_PKG_WINDOWS` → `Path(D_PKG_WINDOWS)`)
- **경로 유틸리티**: `pk_system/pkg_py/system_object/files.py`, `pk_system/pkg_py/system_object/directories.py` 활용

### 🏗️ 코드 구조 규칙
- **클래스 작성**: `pk_system/pkg_py/system_object`에 작성
- **함수 작성**: `pk_system/pkg_py/function_split`에 작성
- **래퍼 패턴**: pkg_py에 래퍼 작성 시 주변 래퍼의 패턴을 비교하여 재생성

### ⚠️ 보안 규칙
- **민감정보 경고**: 비밀번호, API 키 등 민감한 개인정보가 포함된 컨텐츠에 대해 경고 요청

---

### 세부 요청 유형
- **코드 리뷰 및 개선**: 기존 코드의 품질 향상 및 최적화
- **버그 해결**: 발생한 문제점의 원인 분석 및 해결 방안
- **아이디어 브레인스토밍**: 새로운 기능이나 개선 방안에 대한 아이디어 논의
- **콘텐츠 작성 보조**: 문서나 설명서 작성에 대한 도움
- **창작 방향 설정**: 프로젝트의 방향성이나 구조에 대한 가이드
- **개념 설명 요청**: 특정 기술이나 개념에 대한 이해 도움
- **자료 정리 및 요약**: 복잡한 정보의 정리 및 핵심 요약
- **연구 방향 설정**: 기술 조사나 연구 주제 설정에 대한 가이드

---
