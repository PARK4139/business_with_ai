#!/usr/bin/env python3
"""
Frontend Test Setup and Execution Script
Windows ?˜ê²½?ì„œ ?„ë¡ ?¸ì—”???ŒìŠ¤?¸ë? ?„í•œ ?˜ê²½ ?¤ì •ê³??ŒìŠ¤???¤í–‰???ë™?”í•©?ˆë‹¤.
"""

import os
import sys
import subprocess
import platform
import logging
from pathlib import Path
import time

# ë¡œê¹… ?¤ì •
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
    """?„ë¡ ?¸ì—”???ŒìŠ¤???˜ê²½ ?¤ì • ?´ë˜??""
    
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
        """Windows ?˜ê²½ ?•ì¸"""
        if not self.is_windows:
            logger.error("?????¤í¬ë¦½íŠ¸??Windows ?˜ê²½?ì„œë§??¤í–‰?????ˆìŠµ?ˆë‹¤.")
            return False
        
        logger.info("??Windows ?˜ê²½ ?•ì¸ ?„ë£Œ")
        return True
    
    def setup_virtual_environment(self):
        """ê°€?í™˜ê²??¤ì •"""
        logger.info("?”§ ê°€?í™˜ê²??¤ì • ?œì‘...")
        
        try:
            # ê°€?í™˜ê²½ì´ ì¡´ì¬?˜ì? ?Šìœ¼ë©??ì„±
            if not self.venv_path.exists():
                logger.info("?“¦ ?ˆë¡œ??ê°€?í™˜ê²??ì„± ì¤?..")
                result = subprocess.run([
                    sys.executable, "-m", "venv", str(self.venv_path)
                ], capture_output=True, text=True, cwd=self.project_root)
                
                if result.returncode != 0:
                    logger.error(f"??ê°€?í™˜ê²??ì„± ?¤íŒ¨: {result.stderr}")
                    return False
                logger.info("??ê°€?í™˜ê²??ì„± ?„ë£Œ")
            else:
                logger.info("??ê°€?í™˜ê²½ì´ ?´ë? ì¡´ì¬?©ë‹ˆ??)
            
            return True
            
        except Exception as e:
            logger.error(f"??ê°€?í™˜ê²??¤ì • ?¤íŒ¨: {e}")
            return False
    
    def install_pip(self):
        """pip ?¤ì¹˜"""
        logger.info("?“¦ pip ?¤ì¹˜ ì¤?..")
        
        try:
            python_exe = self.venv_path / "Scripts" / "python.exe"
            pip_exe = self.venv_path / "Scripts" / "pip.exe"
            
            if not pip_exe.exists():
                logger.info("?”§ pip ?¤ì¹˜ ì¤?..")
                result = subprocess.run([
                    str(python_exe), "-m", "ensurepip", "--upgrade"
                ], capture_output=True, text=True, cwd=self.project_root)
                
                if result.returncode != 0:
                    logger.error(f"??pip ?¤ì¹˜ ?¤íŒ¨: {result.stderr}")
                    return False
                logger.info("??pip ?¤ì¹˜ ?„ë£Œ")
            else:
                logger.info("??pip???´ë? ?¤ì¹˜?˜ì–´ ?ˆìŠµ?ˆë‹¤")
            
            return True
            
        except Exception as e:
            logger.error(f"??pip ?¤ì¹˜ ?¤íŒ¨: {e}")
            return False
    
    def install_required_packages(self):
        """?„ìš”???¨í‚¤ì§€ ?¤ì¹˜"""
        logger.info("?“š ?„ìš”???¨í‚¤ì§€ ?¤ì¹˜ ?œì‘...")
        
        try:
            python_exe = self.venv_path / "Scripts" / "python.exe"
            pip_exe = self.venv_path / "Scripts" / "pip.exe"
            
            for package in self.required_packages:
                logger.info(f"?“¦ {package} ?¤ì¹˜ ì¤?..")
                
                result = subprocess.run([
                    str(pip_exe), "install", package
                ], capture_output=True, text=True, cwd=self.project_root)
                
                if result.returncode != 0:
                    logger.error(f"??{package} ?¤ì¹˜ ?¤íŒ¨: {result.stderr}")
                    return False
                
                logger.info(f"??{package} ?¤ì¹˜ ?„ë£Œ")
            
            return True
            
        except Exception as e:
            logger.error(f"???¨í‚¤ì§€ ?¤ì¹˜ ?¤íŒ¨: {e}")
            return False
    
    def check_services_running(self):
        """?œë¹„???¤í–‰ ?íƒœ ?•ì¸"""
        logger.info("?” ?œë¹„???¤í–‰ ?íƒœ ?•ì¸ ì¤?..")
        
        try:
            # ê°„ë‹¨??HTTP ?”ì²­?¼ë¡œ ?œë¹„???íƒœ ?•ì¸
            import requests
            
            services = [
                ("Page Server", "http://localhost:3000"),
                ("API Server", "http://localhost:8000"),
                ("Nginx", "http://localhost:80")
            ]
            
            for service_name, url in services:
                try:
                    response = requests.get(url, timeout=5)
                    logger.info(f"??{service_name}: {url} - ?íƒœ ì½”ë“œ: {response.status_code}")
                except requests.exceptions.RequestException as e:
                    logger.warning(f"? ï¸ {service_name}: {url} - ?°ê²° ?¤íŒ¨: {e}")
            
            return True
            
        except ImportError:
            logger.warning("? ï¸ requests ëª¨ë“ˆ???¤ì¹˜?˜ì? ?Šì•„ ?œë¹„???íƒœ ?•ì¸??ê±´ë„ˆ?ë‹ˆ??)
            return True
        except Exception as e:
            logger.error(f"???œë¹„???íƒœ ?•ì¸ ?¤íŒ¨: {e}")
            return False
    
    def run_frontend_tests(self):
        """?„ë¡ ?¸ì—”???ŒìŠ¤???¤í–‰"""
        logger.info("?§ª ?„ë¡ ?¸ì—”???ŒìŠ¤???¤í–‰ ?œì‘...")
        
        try:
            python_exe = self.venv_path / "Scripts" / "python.exe"
            pytest_exe = self.venv_path / "Scripts" / "pytest.exe"
            
            # pytestê°€ ?¤ì¹˜?˜ì–´ ?ˆëŠ”ì§€ ?•ì¸
            if not pytest_exe.exists():
                logger.info("?“¦ pytest ?¤ì¹˜ ì¤?..")
                subprocess.run([
                    str(python_exe), "-m", "pip", "install", "pytest"
                ], cwd=self.project_root)
            
            # ?ŒìŠ¤???¤í–‰
            test_files = [
                "tests/test_frontend_selenium.py",
                "tests/test_frontend_login_routine_via_selenium_at_windows.py"
            ]
            
            for test_file in test_files:
                if Path(test_file).exists():
                    logger.info(f"?§ª {test_file} ?¤í–‰ ì¤?..")
                    
                    result = subprocess.run([
                        str(python_exe), "-m", "pytest", test_file, "-v", "--tb=short"
                    ], cwd=self.project_root)
                    
                    if result.returncode == 0:
                        logger.info(f"??{test_file} ?ŒìŠ¤???µê³¼")
                    else:
                        logger.warning(f"? ï¸ {test_file} ?ŒìŠ¤???¼ë? ?¤íŒ¨")
                else:
                    logger.warning(f"? ï¸ {test_file} ?Œì¼??ì°¾ì„ ???†ìŠµ?ˆë‹¤")
            
            return True
            
        except Exception as e:
            logger.error(f"???ŒìŠ¤???¤í–‰ ?¤íŒ¨: {e}")
            return False
    
    def setup_logs_directory(self):
        """ë¡œê·¸ ?”ë ‰? ë¦¬ ?¤ì •"""
        logs_dir = self.project_root / "logs"
        logs_dir.mkdir(exist_ok=True)
        logger.info(f"??ë¡œê·¸ ?”ë ‰? ë¦¬ ?•ì¸: {logs_dir}")
    
    def run_setup(self):
        """?„ì²´ ?¤ì • ë°??ŒìŠ¤???¤í–‰"""
        logger.info("?? Frontend Test Setup ?œì‘")
        logger.info("=" * 50)
        
        try:
            # 1. Windows ?˜ê²½ ?•ì¸
            if not self.check_windows_environment():
                return False
            
            # 2. ë¡œê·¸ ?”ë ‰? ë¦¬ ?¤ì •
            self.setup_logs_directory()
            
            # 3. ê°€?í™˜ê²??¤ì •
            if not self.setup_virtual_environment():
                return False
            
            # 4. pip ?¤ì¹˜
            if not self.install_pip():
                return False
            
            # 5. ?„ìš”???¨í‚¤ì§€ ?¤ì¹˜
            if not self.install_required_packages():
                return False
            
            # 6. ?œë¹„???íƒœ ?•ì¸
            self.check_services_running()
            
            # 7. ?„ë¡ ?¸ì—”???ŒìŠ¤???¤í–‰
            if not self.run_frontend_tests():
                return False
            
            logger.info("=" * 50)
            logger.info("?‰ Frontend Test Setup ?„ë£Œ!")
            logger.info("?’¡ ë¡œê·¸ ?Œì¼: logs/frontend_test_setup.log")
            
            return True
            
        except Exception as e:
            logger.error(f"???¤ì • ì¤??¤ë¥˜ ë°œìƒ: {e}")
            return False


def main():
    """ë©”ì¸ ?¨ìˆ˜"""
    setup = FrontendTestSetup()
    
    if setup.run_setup():
        logger.info("??ëª¨ë“  ?‘ì—…???±ê³µ?ìœ¼ë¡??„ë£Œ?˜ì—ˆ?µë‹ˆ??")
        sys.exit(0)
    else:
        logger.error("???¼ë? ?‘ì—…???¤íŒ¨?ˆìŠµ?ˆë‹¤. ë¡œê·¸ë¥??•ì¸?´ì£¼?¸ìš”.")
        sys.exit(1)


if __name__ == "__main__":
    main()
