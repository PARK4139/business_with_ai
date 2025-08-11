@echo off
REM Windows 전용: 로그인 루틴 테스트 실행 스크립트
setlocal
cd /d %~dp0\..

set VENV=.\.venv_windows\Scripts\python.exe

if not exist %VENV% (
  echo [INFO] Windows 가상환경 생성 중... (.venv_windows)
  where py >nul 2>nul && ( py -3 -m venv .venv_windows ) || ( python -m venv .venv_windows )
)

if not exist %VENV% (
  echo [ERROR] Windows 가상환경을 찾을 수 없습니다: services\hospital_workers\.venv_windows\Scripts\python.exe
  exit /b 1
)

echo [INFO] 의존성 설치/업데이트...
%VENV% -m pip install -q --upgrade pip setuptools wheel
%VENV% -m pip install -q selenium webdriver-manager pytest pytest-html requests

echo [INFO] 로그인 루틴 테스트 실행...
%VENV% -m pytest tests\test_login_routine_via_selenium_at_windows.py -k "test_page_load_and_title or test_login_form_structure or test_form_interaction or test_browser_functionality" -v -s --html logs\login_report_windows.html --self-contained-html

echo [DONE] 리포트: services\hospital_workers\logs\login_report_windows.html
endlocal
