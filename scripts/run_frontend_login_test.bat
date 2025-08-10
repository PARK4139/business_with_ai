@echo off
echo ========================================
echo Hospital Workers Management System
echo Frontend Login Test (Windows)
echo ========================================
echo.

echo 1. Moving to project directory...
echo Current directory: %CD%
echo.

REM Try to find the project directory automatically
echo Searching for project directory automatically...
echo.

REM Method 1: Check if we're already in the project directory
if exist "tests\test_frontend_login_routine_via_selenium_at_windows.bat" (
    echo SUCCESS: Already in project directory
    goto :continue_setup
)

REM Method 2: Check common Windows paths
echo Checking common Windows paths...
if exist "C:\Users\%USERNAME%\Downloads\business_with_ai" (
    echo Found: C:\Users\%USERNAME%\Downloads\business_with_ai
    cd /d "C:\Users\%USERNAME%\Downloads\business_with_ai"
    goto :continue_setup
) else if exist "C:\Users\%USERNAME%\Desktop\business_with_ai" (
    echo Found: C:\Users\%USERNAME%\Desktop\business_with_ai
    cd /d "C:\Users\%USERNAME%\Desktop\business_with_ai"
    goto :continue_setup
) else if exist "C:\business_with_ai" (
    echo Found: C:\business_with_ai
    cd /d "C:\business_with_ai"
    goto :continue_setup
) else if exist "D:\business_with_ai" (
    echo Found: D:\business_with_ai
    cd /d "D:\business_with_ai"
    goto :continue_setup
)

REM Method 3: Check WSL paths
echo Checking WSL paths...
if exist "\\wsl.localhost\Ubuntu-24.04\home\%USERNAME%\Downloads\business_with_ai" (
    echo Found: \\wsl.localhost\Ubuntu-24.04\home\%USERNAME%\Downloads\business_with_ai
    cd /d "\\wsl.localhost\Ubuntu-24.04\home\%USERNAME%\Downloads\business_with_ai"
    goto :continue_setup
) else if exist "\\wsl.localhost\Ubuntu-24.04\home\pk\Downloads\business_with_ai" (
    echo Found: \\wsl.localhost\Ubuntu-24.04\home\pk\Downloads\business_with_ai
    cd /d "\\wsl.localhost\Ubuntu-24.04\home\pk\Downloads\business_with_ai"
    goto :continue_setup
)

REM Method 4: Ask user for manual input
echo.
echo ERROR: Project directory not found automatically
echo.
echo Please provide the project directory path manually:
echo Example: C:\Users\%USERNAME%\Downloads\business_with_ai
echo.
set /p PROJECT_PATH="Enter project directory path: "
if exist "!PROJECT_PATH!" (
    cd /d "!PROJECT_PATH!"
    if exist "tests\test_frontend_login_routine_via_selenium_at_windows.bat" (
        echo SUCCESS: Project directory reached via manual input
    ) else (
        echo ERROR: Invalid project directory (test file not found)
        pause
        exit /b 1
    )
) else (
    echo ERROR: Invalid path provided
    pause
    exit /b 1
)

:continue_setup
echo.
echo 2. Using uv .venv_windows virtual environment...
if not exist ".venv_windows" (
    echo ERROR: .venv_windows directory not found
    echo Please create virtual environment first
    echo.
    echo To create virtual environment, run:
    echo   uv venv .venv_windows
    pause
    exit /b 1
)

echo SUCCESS: .venv_windows directory found
echo.

echo 3. Installing required packages with uv...
uv pip install pytest selenium webdriver-manager requests
if %errorlevel% neq 0 (
    echo ERROR: Package installation failed
    pause
    exit /b 1
)
echo SUCCESS: Required packages installed
echo.

echo 4. Running Frontend Login Tests with uv...
echo Test Account: foo@foo / foo
echo Test Target: Frontend Login Function
echo Test Method: Selenium Automation Test
echo.

echo [TEST] Dummy Account Login Test...
uv run python -m pytest tests\test_frontend_login_routine_via_selenium.py::TestFrontendLoginRoutine::test_login_with_dummy_credentials -v -s

echo.
echo [TEST] Complete Frontend Login Test Suite...
uv run python -m pytest tests\test_frontend_login_routine_via_selenium.py -v -s

echo.
echo ========================================
echo TEST COMPLETED!
echo ========================================
echo.
echo Result Files:
echo - frontend_login_test.log (Test Log)
echo - dummy_login_test_result.png (Dummy Account Test Screenshot)
echo - dummy_login_test_failed.png (Dummy Account Test Failed Screenshot)
echo - login_test_result.png (General Login Test Screenshot)
echo - invalid_login_test_result.png (Invalid Credentials Test Screenshot)
echo.
echo Additional Test Options:
echo - Run specific test: uv run python -m pytest tests\test_frontend_login_routine_via_selenium.py::TestFrontendLoginRoutine::test_name -v -s
echo - Disable headless mode: Remove --headless option in test file
echo.
echo Test Summary:
echo - Dummy Account (foo@foo/foo) Login Test
echo - Valid Credentials Login Test
echo - Invalid Credentials Login Test
echo - Form Structure and Validation Test
echo - Responsive Design Test
echo - Performance and Load Time Test
echo.
pause
