@echo off
chcp 65001 >nul
echo ========================================
echo 🚀 Frontend Test Setup and Execution
echo ========================================
echo.

REM 현재 디렉토리를 프로젝트 루트로 변경
cd /d "%~dp0.."

REM Python이 설치되어 있는지 확인
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python이 설치되어 있지 않습니다.
    echo Python을 설치한 후 다시 시도해주세요.
    pause
    exit /b 1
)

echo ✅ Python 환경 확인 완료
echo.

REM 통합 스크립트 실행
echo 🔧 프론트엔드 테스트 환경 설정 및 실행 중...
python scripts/setup_and_run_frontend_tests.py

if errorlevel 1 (
    echo.
    echo ❌ 테스트 실행 중 오류가 발생했습니다.
    echo logs/frontend_test_setup.log 파일을 확인해주세요.
) else (
    echo.
    echo 🎉 모든 테스트가 성공적으로 완료되었습니다!
)

echo.
echo 💡 로그 파일: logs/frontend_test_setup.log
echo 💡 테스트 결과: logs/frontend_selenium_test.log
echo.
pause
