### 비지니스 기획 업데이트 요청
1. DDD 아키텍처 구조, MSA, Docker 는 MSA 단위로 구성
2. 구성 : 로그인서버, api서버, user DB
3. api :  fastapi
4. 환경 : 서비스운영(docker-compose, docker-compose.dev, docker-compose.prod), 파이썬가상환경(uv.lock, pyproject.toml) 
5. urls designs sample
heal_base_hospital_worker/v1/api/ensure/login/                     # 로그인 api
heal_base_hospital_worker/v1/web/ensure/login/                     # 로그인 (메인화면)
heal_base_hospital_worker/v1/web/ensure/login-guide/               # 로그인 (가이드)
heal_base_hospital_worker/v1/web/ensure/login-via-google            # 로그인 (구글)
heal_base_hospital_worker/v1/web/ensure/signup/                    # 회원가입
heal_base_hospital_worker/v1/web/ensure/signup-form-submit/        # 회원가입 폼 작성 및 제출
heal_base_hospital_worker/v1/web/ensure/signup-complete/           # 회원가입 완료 페이지
heal_base_hospital_worker/v1/web/ensure/logined/and/hospital-location-guided/{실}         # 실별위치가이드 + 광고
___________________________________________________________
### 프로젝트 구조 생성요청
1. TBD
___________________________________________________________
### 프로젝트 구조 재숙지요청
1. 프로젝트 내부를 순회하며 프로젝트 구조 분석
2. 분석 결과을 사용자 질의하여 검토요청
___________________________________________________________
### 커밋 자동화 요청 
1. 현재 프로젝트의 작업내용을 포괄하는 적당한 한글 커밋멘트 4개 후보 제안
2. 후보 중 사용자가 선택한 메시지로 git push 요청
3. 앞으로의 작업에 대해서도 특정 작업이 완료되면 커밋 자동화 실행여부를 제안
___________________________________________________________
### 도커빌드최적화 요청
1. docker-compose.dev/docker-compose.prod 구분
2. docker-compose.dev 에는 개발속도가 빠르도록  볼륨 마운트로 코드 변경사항 즉시 반영, 멀티스테이지 빌드로 이미지 크기 최소화

___________________________________________________________
### 개발 진행요청
1. 프론트엔드 개발프론트엔드 개발 요청

___________________________________________________________
### 문재해결을 위한 코드 수정 및 테스트 재진행요청
1. 문제 : target api-service: failed to solve: process "/bin/sh -c uv sync" did not complete successfully: exit code: 1
2. 코드 수정 및 테스트 재진행
___________________________________________________________
### 서비스 코드베이스 빌드 및 실행 자동화 요청 
1. 도커컨테이너 빌드 자동화스크립트 scripts/ 에 작성요청
2. 도커컨테이너 실행 자동화스크립트 scripts/ 에 작성요청
3. 도커컨테이너 실행 자동화스크립트 scripts/ 에 작성요청
4. scripts/ 의 서비스 빌드 관련 테스트 실행요청
5. 테스트 수행전 모든 도커컨테이너 kill 요청
6. ./scripts/ensure_service_tested.sh 작성 및 실행 요청 # 실행시 서비스별 컨테이너가 동작상태 콘솔출력
7. ./scripts/ensure_service_operated_as_dev.sh 작성 및 실행 요청 # 실행시 서비스별 컨테이너가 동작상태 콘솔출력
8. ./scripts/ensure_service_operated.sh 작성 및 실행 요청 # 서비스 operation 용 스크립트, 실행시 서비스별 컨테이너가 동작상태 콘솔출력
___________________________________________________________
### API 테스트 수행요청
1. 서비스의 모든 api 테스트 수행요청 scripts/all_api_test.py 생성 후 실행.
2. 수행결과 형태는 api 호출결과를 logs/all_api_test.log에 저장 후
3. 결과를 확인할 수 있도록 log 파일을 open 
___________________________________________________________
### docs 업데이트 요청
1. README.md 에 오늘 작업한 내용에 대해서 내용 추가작성
2. 오늘 지금까지 나눈 대화에 대해서 prompts/chatting_room_with_ai.md 에 추가작성요청
___________________________________________________________
### 커밋 요청 
1. 지난 commit 이후의 지금까지의 작업에 대한 적당한 한글 커밋멘트 4개 후보 제안
2. 후보 중 사용자가 선택한 메시지로 git push 요청
___________________________________________________________
### 배포 자동화 방법제안요청
___________________________________________________________
### 배포 자동화 요청
___________________________________________________________
### 2025 TODO 
가방/두꺼운 바지
가방/휴지
가방 챙기기
스타벅스 출발
주식투자(한국장 500만원)
fin_service 개발
    정보 수집
        자산정보_수동수집   계좌별 자산정보, 부동산...
        정보 크롤링
        정보 api 
        정보 DB 저장
    정보 분석
    정보 시현
        web
        엑셀파일
    분석결과로 투자가이드
구직활동(알바천국)
영화보기
준희랑 점심식사
안양/보건증
점빼기 # 가을 추천
___________________________________________________________
### 정리중인 메모
AI비니 : AI 와 비지니스하기
도메인 후보 : pk-business.ai
1. 웹/앱/유튜브 광고수익구조 시장조사 요청
1. 웹/앱 광고수익구조 알려줄래 안드로이드/IOS 모두 비교요청
2. 아이템 시장조사 요청
2. DDD기반 개발/유지보수를 위한 탬플릿 요청 
0. 비지니스 기획요청
telegram 같은 web 하이브리드 앱을 만들고 싶어
ws:\\chat/with_advertisement