#!/usr/bin/env python3
"""
Frontend Test Setup and Execution Script
Windows ?�경?�서 ?�론?�엔???�스?��? ?�한 ?�경 ?�정�??�스???�행???�동?�합?�다.
"""

import os
import sys
import subprocess
import platform
import logging
from pathlib import Path
import time

# 로깅 ?�정
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
    """?�론?�엔???�스???�경 ?�정 ?�래??""
    
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
        """Windows ?�경 ?�인"""
        if not self.is_windows:
            logger.error("?????�크립트??Windows ?�경?�서�??�행?????�습?�다.")
            return False
        
        logger.info("??Windows ?�경 ?�인 ?�료")
        return True
    
    def setup_virtual_environment(self):
        """가?�환�??�정"""
        logger.info("?�� 가?�환�??�정 ?�작...")
        
        try:
            # 가?�환경이 존재?��? ?�으�??�성
            if not self.venv_path.exists():
                logger.info("?�� ?�로??가?�환�??�성 �?..")
                result = subprocess.run([
                    sys.executable, "-m", "venv", str(self.venv_path)
                ], capture_output=True, text=True, cwd=self.project_root)
                
                if result.returncode != 0:
                    logger.error(f"??가?�환�??�성 ?�패: {result.stderr}")
                    return False
                logger.info("??가?�환�??�성 ?�료")
            else:
                logger.info("??가?�환경이 ?��? 존재?�니??)
            
            return True
            
        except Exception as e:
            logger.error(f"??가?�환�??�정 ?�패: {e}")
            return False
    
    def install_pip(self):
        """pip ?�치"""
        logger.info("?�� pip ?�치 �?..")
        
        try:
            python_exe = self.venv_path / "Scripts" / "python.exe"
            pip_exe = self.venv_path / "Scripts" / "pip.exe"
            
            if not pip_exe.exists():
                logger.info("?�� pip ?�치 �?..")
                result = subprocess.run([
                    str(python_exe), "-m", "ensurepip", "--upgrade"
                ], capture_output=True, text=True, cwd=self.project_root)
                
                if result.returncode != 0:
                    logger.error(f"??pip ?�치 ?�패: {result.stderr}")
                    return False
                logger.info("??pip ?�치 ?�료")
            else:
                logger.info("??pip???��? ?�치?�어 ?�습?�다")
            
            return True
            
        except Exception as e:
            logger.error(f"??pip ?�치 ?�패: {e}")
            return False
    
    def install_required_packages(self):
        """?�요???�키지 ?�치"""
        logger.info("?�� ?�요???�키지 ?�치 ?�작...")
        
        try:
            python_exe = self.venv_path / "Scripts" / "python.exe"
            pip_exe = self.venv_path / "Scripts" / "pip.exe"
            
            for package in self.required_packages:
                logger.info(f"?�� {package} ?�치 �?..")
                
                result = subprocess.run([
                    str(pip_exe), "install", package
                ], capture_output=True, text=True, cwd=self.project_root)
                
                if result.returncode != 0:
                    logger.error(f"??{package} ?�치 ?�패: {result.stderr}")
                    return False
                
                logger.info(f"??{package} ?�치 ?�료")
            
            return True
            
        except Exception as e:
            logger.error(f"???�키지 ?�치 ?�패: {e}")
            return False
    
    def check_services_running(self):
        """?�비???�행 ?�태 ?�인"""
        logger.info("?�� ?�비???�행 ?�태 ?�인 �?..")
        
        try:
            # 간단??HTTP ?�청?�로 ?�비???�태 ?�인
            import requests
            
            services = [
                ("Page Server", "http://localhost:3000"),
                ("API Server", "http://localhost:8000"),
                ("Nginx", "http://localhost:80")
            ]
            
            for service_name, url in services:
                try:
                    response = requests.get(url, timeout=5)
                    logger.info(f"??{service_name}: {url} - ?�태 코드: {response.status_code}")
                except requests.exceptions.RequestException as e:
                    logger.warning(f"?�️ {service_name}: {url} - ?�결 ?�패: {e}")
            
            return True
            
        except ImportError:
            logger.warning("?�️ requests 모듈???�치?��? ?�아 ?�비???�태 ?�인??건너?�니??)
            return True
        except Exception as e:
            logger.error(f"???�비???�태 ?�인 ?�패: {e}")
            return False
    
    def run_frontend_tests(self):
        """?�론?�엔???�스???�행"""
        logger.info("?�� ?�론?�엔???�스???�행 ?�작...")
        
        try:
            python_exe = self.venv_path / "Scripts" / "python.exe"
            pytest_exe = self.venv_path / "Scripts" / "pytest.exe"
            
            # pytest가 ?�치?�어 ?�는지 ?�인
            if not pytest_exe.exists():
                logger.info("?�� pytest ?�치 �?..")
                subprocess.run([
                    str(python_exe), "-m", "pip", "install", "pytest"
                ], cwd=self.project_root)
            
            # ?�스???�행
            test_files = [
                "tests/test_frontend_selenium.py",
                "tests/test_frontend_login_routine_via_selenium_at_windows.py"
            ]
            
            for test_file in test_files:
                if Path(test_file).exists():
                    logger.info(f"?�� {test_file} ?�행 �?..")
                    
                    result = subprocess.run([
                        str(python_exe), "-m", "pytest", test_file, "-v", "--tb=short"
                    ], cwd=self.project_root)
                    
                    if result.returncode == 0:
                        logger.info(f"??{test_file} ?�스???�과")
                    else:
                        logger.warning(f"?�️ {test_file} ?�스???��? ?�패")
                else:
                    logger.warning(f"?�️ {test_file} ?�일??찾을 ???�습?�다")
            
            return True
            
        except Exception as e:
            logger.error(f"???�스???�행 ?�패: {e}")
            return False
    
    def setup_logs_directory(self):
        """로그 ?�렉?�리 ?�정"""
        logs_dir = self.project_root / "logs"
        logs_dir.mkdir(exist_ok=True)
        logger.info(f"??로그 ?�렉?�리 ?�인: {logs_dir}")
    
    def run_setup(self):
        """?�체 ?�정 �??�스???�행"""
        logger.info("?? Frontend Test Setup ?�작")
        logger.info("=" * 50)
        
        try:
            # 1. Windows ?�경 ?�인
            if not self.check_windows_environment():
                return False
            
            # 2. 로그 ?�렉?�리 ?�정
            self.setup_logs_directory()
            
            # 3. 가?�환�??�정
            if not self.setup_virtual_environment():
                return False
            
            # 4. pip ?�치
            if not self.install_pip():
                return False
            
            # 5. ?�요???�키지 ?�치
            if not self.install_required_packages():
                return False
            
            # 6. ?�비???�태 ?�인
            self.check_services_running()
            
            # 7. ?�론?�엔???�스???�행
            if not self.run_frontend_tests():
                return False
            
            logger.info("=" * 50)
            logger.info("?�� Frontend Test Setup ?�료!")
            logger.info("?�� 로그 ?�일: logs/frontend_test_setup.log")
            
            return True
            
        except Exception as e:
            logger.error(f"???�정 �??�류 발생: {e}")
            return False


def main():
    """메인 ?�수"""
    setup = FrontendTestSetup()
    
    if setup.run_setup():
        logger.info("??모든 ?�업???�공?�으�??�료?�었?�니??")
        sys.exit(0)
    else:
        logger.error("???��? ?�업???�패?�습?�다. 로그�??�인?�주?�요.")
        sys.exit(1)


if __name__ == "__main__":
    main()
