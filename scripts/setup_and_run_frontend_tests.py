#!/usr/bin/env python3
"""
Frontend Test Setup and Execution Script
Windows 환경에서 프론트엔드 테스트를 위한 환경 설정과 테스트 실행을 자동화합니다.
"""

import os
import sys
import subprocess
import platform
import logging
from pathlib import Path
import time

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/frontend_test_setup.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class FrontendTestSetup:
    """프론트엔드 테스트 환경 설정 클래스"""
    
    def __init__(self):
        self.project_root = Path(__file__).parent.parent
        self.venv_path = self.project_root / ".venv_windows"
        self.is_windows = platform.system().lower() == "windows"
        self.required_packages = [
            "selenium",
            "webdriver-manager", 
            "pytest",
            "pytest-html",
            "requests"
        ]
        
    def check_windows_environment(self):
        """Windows 환경 확인"""
        if not self.is_windows:
            logger.error("❌ 이 스크립트는 Windows 환경에서만 실행할 수 있습니다.")
            return False
        
        logger.info("✅ Windows 환경 확인 완료")
        return True
    
    def setup_virtual_environment(self):
        """가상환경 설정"""
        logger.info("🔧 가상환경 설정 시작...")
        
        try:
            # 가상환경이 존재하지 않으면 생성
            if not self.venv_path.exists():
                logger.info("📦 새로운 가상환경 생성 중...")
                result = subprocess.run([
                    sys.executable, "-m", "venv", str(self.venv_path)
                ], capture_output=True, text=True, cwd=self.project_root)
                
                if result.returncode != 0:
                    logger.error(f"❌ 가상환경 생성 실패: {result.stderr}")
                    return False
                logger.info("✅ 가상환경 생성 완료")
            else:
                logger.info("✅ 가상환경이 이미 존재합니다")
            
            return True
            
        except Exception as e:
            logger.error(f"❌ 가상환경 설정 실패: {e}")
            return False
    
    def install_pip(self):
        """pip 설치"""
        logger.info("📦 pip 설치 중...")
        
        try:
            python_exe = self.venv_path / "Scripts" / "python.exe"
            pip_exe = self.venv_path / "Scripts" / "pip.exe"
            
            if not pip_exe.exists():
                logger.info("🔧 pip 설치 중...")
                result = subprocess.run([
                    str(python_exe), "-m", "ensurepip", "--upgrade"
                ], capture_output=True, text=True, cwd=self.project_root)
                
                if result.returncode != 0:
                    logger.error(f"❌ pip 설치 실패: {result.stderr}")
                    return False
                logger.info("✅ pip 설치 완료")
            else:
                logger.info("✅ pip이 이미 설치되어 있습니다")
            
            return True
            
        except Exception as e:
            logger.error(f"❌ pip 설치 실패: {e}")
            return False
    
    def install_required_packages(self):
        """필요한 패키지 설치"""
        logger.info("📚 필요한 패키지 설치 시작...")
        
        try:
            python_exe = self.venv_path / "Scripts" / "python.exe"
            pip_exe = self.venv_path / "Scripts" / "pip.exe"
            
            for package in self.required_packages:
                logger.info(f"📦 {package} 설치 중...")
                
                result = subprocess.run([
                    str(pip_exe), "install", package
                ], capture_output=True, text=True, cwd=self.project_root)
                
                if result.returncode != 0:
                    logger.error(f"❌ {package} 설치 실패: {result.stderr}")
                    return False
                
                logger.info(f"✅ {package} 설치 완료")
            
            return True
            
        except Exception as e:
            logger.error(f"❌ 패키지 설치 실패: {e}")
            return False
    
    def check_services_running(self):
        """서비스 실행 상태 확인"""
        logger.info("🔍 서비스 실행 상태 확인 중...")
        
        try:
            # 간단한 HTTP 요청으로 서비스 상태 확인
            import requests
            
            services = [
                ("Page Server", "http://localhost:3000"),
                ("API Server", "http://localhost:8000"),
                ("Nginx", "http://localhost:80")
            ]
            
            for service_name, url in services:
                try:
                    response = requests.get(url, timeout=5)
                    logger.info(f"✅ {service_name}: {url} - 상태 코드: {response.status_code}")
                except requests.exceptions.RequestException as e:
                    logger.warning(f"⚠️ {service_name}: {url} - 연결 실패: {e}")
            
            return True
            
        except ImportError:
            logger.warning("⚠️ requests 모듈이 설치되지 않아 서비스 상태 확인을 건너뜁니다")
            return True
        except Exception as e:
            logger.error(f"❌ 서비스 상태 확인 실패: {e}")
            return False
    
    def run_frontend_tests(self):
        """프론트엔드 테스트 실행"""
        logger.info("🧪 프론트엔드 테스트 실행 시작...")
        
        try:
            python_exe = self.venv_path / "Scripts" / "python.exe"
            pytest_exe = self.venv_path / "Scripts" / "pytest.exe"
            
            # pytest가 설치되어 있는지 확인
            if not pytest_exe.exists():
                logger.info("📦 pytest 설치 중...")
                subprocess.run([
                    str(python_exe), "-m", "pip", "install", "pytest"
                ], cwd=self.project_root)
            
            # 테스트 실행
            test_files = [
                "tests/test_frontend_selenium.py",
                "tests/test_frontend_login_routine_via_selenium_at_windows.py"
            ]
            
            for test_file in test_files:
                if Path(test_file).exists():
                    logger.info(f"🧪 {test_file} 실행 중...")
                    
                    result = subprocess.run([
                        str(python_exe), "-m", "pytest", test_file, "-v", "--tb=short"
                    ], cwd=self.project_root)
                    
                    if result.returncode == 0:
                        logger.info(f"✅ {test_file} 테스트 통과")
                    else:
                        logger.warning(f"⚠️ {test_file} 테스트 일부 실패")
                else:
                    logger.warning(f"⚠️ {test_file} 파일을 찾을 수 없습니다")
            
            return True
            
        except Exception as e:
            logger.error(f"❌ 테스트 실행 실패: {e}")
            return False
    
    def setup_logs_directory(self):
        """로그 디렉토리 설정"""
        logs_dir = self.project_root / "logs"
        logs_dir.mkdir(exist_ok=True)
        logger.info(f"✅ 로그 디렉토리 확인: {logs_dir}")
    
    def run_setup(self):
        """전체 설정 및 테스트 실행"""
        logger.info("🚀 Frontend Test Setup 시작")
        logger.info("=" * 50)
        
        try:
            # 1. Windows 환경 확인
            if not self.check_windows_environment():
                return False
            
            # 2. 로그 디렉토리 설정
            self.setup_logs_directory()
            
            # 3. 가상환경 설정
            if not self.setup_virtual_environment():
                return False
            
            # 4. pip 설치
            if not self.install_pip():
                return False
            
            # 5. 필요한 패키지 설치
            if not self.install_required_packages():
                return False
            
            # 6. 서비스 상태 확인
            self.check_services_running()
            
            # 7. 프론트엔드 테스트 실행
            if not self.run_frontend_tests():
                return False
            
            logger.info("=" * 50)
            logger.info("🎉 Frontend Test Setup 완료!")
            logger.info("💡 로그 파일: logs/frontend_test_setup.log")
            
            return True
            
        except Exception as e:
            logger.error(f"❌ 설정 중 오류 발생: {e}")
            return False


def main():
    """메인 함수"""
    setup = FrontendTestSetup()
    
    if setup.run_setup():
        logger.info("✅ 모든 작업이 성공적으로 완료되었습니다!")
        sys.exit(0)
    else:
        logger.error("❌ 일부 작업이 실패했습니다. 로그를 확인해주세요.")
        sys.exit(1)


if __name__ == "__main__":
    main()
