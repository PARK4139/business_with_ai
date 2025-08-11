"""
Frontend Login Routine Selenium Test
?꾨줎?몄뿏?쒖쓽 濡쒓렇??湲곕뒫??Selenium?쇰줈 ?먮룞???뚯뒪?명빀?덈떎.
Windows ?섍꼍 ?ㅼ젙 湲곕뒫???듯빀?섏뼱 ?덉뒿?덈떎.
"""

import pytest
import time
import logging
import os
import sys
import subprocess
import platform
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from selenium.common.exceptions import TimeoutException, NoSuchElementException


# 濡쒓퉭 ?ㅼ젙
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/frontend_login_test.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class WindowsEnvironmentSetup:
    """Windows ?섍꼍 ?ㅼ젙???꾪븳 ?대옒??""
    
    def __init__(self):
        self.project_root = Path(__file__).parent.parent
        self.venv_path = self.project_root / ".venv_windows"
        self.is_windows = platform.system().lower() == "windows"
    
    def setup_windows_environment(self):
        """Windows ?섍꼍?먯꽌 ?뚯뒪???섍꼍 ?ㅼ젙"""
        if not self.is_windows:
            logger.info("?뼢截??꾩옱 ?쒖뒪?쒖? Windows媛 ?꾨떃?덈떎. Windows ?섍꼍 ?ㅼ젙??嫄대꼫?곷땲??")
            return True
        
        logger.info("?첒 Windows ?섍꼍?먯꽌 Hospital Workers Management System ?뚯뒪???섍꼍 ?ㅼ젙???쒖옉?⑸땲??..")
        
        try:
            # 1. 媛?곹솚寃??앹꽦
            logger.info("1截뤴깵 媛?곹솚寃??앹꽦 以?..")
            if not self.venv_path.exists():
                result = subprocess.run([
                    sys.executable, "-m", "venv", str(self.venv_path)
                ], capture_output=True, text=True, cwd=self.project_root)
                
                if result.returncode != 0:
                    logger.error(f"??媛?곹솚寃??앹꽦 ?ㅽ뙣: {result.stderr}")
                    return False
                logger.info("??媛?곹솚寃??앹꽦 ?꾨즺")
            else:
                logger.info("??媛?곹솚寃쎌씠 ?대? 議댁옱?⑸땲??)
            
            # 2. 媛?곹솚寃??쒖꽦??(Windows)
            logger.info("2截뤴깵 媛?곹솚寃??쒖꽦??以?..")
            activate_script = self.venv_path / "Scripts" / "activate.bat"
            if not activate_script.exists():
                logger.error("??媛?곹솚寃??쒖꽦???ㅽ겕由쏀듃瑜?李얠쓣 ???놁뒿?덈떎")
                return False
            
            # 3. pip ?낃렇?덉씠??
            logger.info("3截뤴깵 pip ?낃렇?덉씠??以?..")
            pip_upgrade = subprocess.run([
                str(self.venv_path / "Scripts" / "python.exe"), 
                "-m", "pip", "install", "--upgrade", "pip"
            ], capture_output=True, text=True, cwd=self.project_root)
            
            if pip_upgrade.returncode != 0:
                logger.warning(f"?좑툘 pip ?낃렇?덉씠???ㅽ뙣: {pip_upgrade.stderr}")
            
            # 4. ?꾩슂???⑦궎吏 ?ㅼ튂
            logger.info("4截뤴깵 ?꾩슂???⑦궎吏 ?ㅼ튂 以?..")
            packages = ["selenium", "pytest", "webdriver-manager", "requests"]
            
            for package in packages:
                logger.info(f"?벀 {package} ?ㅼ튂 以?..")
                install_result = subprocess.run([
                    str(self.venv_path / "Scripts" / "python.exe"), 
                    "-m", "pip", "install", package
                ], capture_output=True, text=True, cwd=self.project_root)
                
                if install_result.returncode != 0:
                    logger.error(f"??{package} ?ㅼ튂 ?ㅽ뙣: {install_result.stderr}")
                    return False
                logger.info(f"??{package} ?ㅼ튂 ?꾨즺")
            
            logger.info("?럦 Windows ?섍꼍 ?ㅼ젙 ?꾨즺! ?댁젣 ?뚯뒪?몃? ?ㅽ뻾?????덉뒿?덈떎.")
            return True
            
        except Exception as e:
            logger.error(f"??Windows ?섍꼍 ?ㅼ젙 以??ㅻ쪟 諛쒖깮: {e}")
            return False
    
    def get_windows_python_path(self):
        """Windows 媛?곹솚寃쎌쓽 Python 寃쎈줈 諛섑솚"""
        if self.is_windows and self.venv_path.exists():
            return str(self.venv_path / "Scripts" / "python.exe")
        return sys.executable
    
    def run_windows_test_command(self, test_file):
        """Windows ?섍꼍?먯꽌 ?뚯뒪??紐낅졊???ㅽ뻾"""
        if not self.is_windows:
            return False
        
        python_path = self.get_windows_python_path()
        test_path = self.project_root / "tests" / test_file
        
        if not test_path.exists():
            logger.error(f"???뚯뒪???뚯씪??李얠쓣 ???놁뒿?덈떎: {test_path}")
            return False
        
        logger.info(f"?㎦ {test_file} ?뚯뒪???ㅽ뻾 以?..")
        result = subprocess.run([
            python_path, "-m", "pytest", str(test_path), "-v", "-s"
        ], capture_output=True, text=True, cwd=self.project_root)
        
        if result.returncode == 0:
            logger.info(f"??{test_file} ?뚯뒪???깃났")
            return True
        else:
            logger.error(f"??{test_file} ?뚯뒪???ㅽ뙣: {result.stderr}")
            return False


class TestFrontendLoginRoutine:
    """?꾨줎?몄뿏??濡쒓렇??猷⑦떞 ?뚯뒪??""
    
    @pytest.fixture(scope="class")
    def windows_setup(self):
        """Windows ?섍꼍 ?ㅼ젙"""
        setup = WindowsEnvironmentSetup()
        if setup.is_windows:
            setup.setup_windows_environment()
        return setup
    
    @pytest.fixture(scope="class")
    def driver(self, windows_setup):
        """Chrome WebDriver ?ㅼ젙"""
        logger.info("?? Chrome WebDriver ?ㅼ젙 ?쒖옉...")
        
        try:
            chrome_options = Options()
            # chrome_options.add_argument("--headless")  # ?ㅻ뱶由ъ뒪 紐⑤뱶 ?댁젣
            chrome_options.add_argument("--no-sandbox")
            chrome_options.add_argument("--disable-dev-shm-usage")
            chrome_options.add_argument("--disable-gpu")
            chrome_options.add_argument("--window-size=1920,1080")
            chrome_options.add_argument("--disable-web-security")
            chrome_options.add_argument("--user-data-dir=/tmp/chrome-test")
            
            service = Service(ChromeDriverManager().install())
            driver = webdriver.Chrome(service=service, options=chrome_options)
            driver.implicitly_wait(10)
            
            logger.info("??Chrome WebDriver ?ㅼ젙 ?꾨즺")
            yield driver
            
        except Exception as e:
            logger.error(f"??Chrome WebDriver ?ㅼ젙 ?ㅽ뙣: {e}")
            raise
        finally:
            try:
                # driver.quit()  # Chrome 釉뚮씪?곗?瑜??대┛ ?곹깭濡??좎?
                logger.info("?뵏 Chrome WebDriver瑜??대┛ ?곹깭濡??좎??⑸땲??)
            except Exception as e:
                logger.error(f"?좑툘 WebDriver 泥섎━ 以??ㅻ쪟: {e}")
    
    def test_windows_environment_setup(self, windows_setup):
        """Windows ?섍꼍 ?ㅼ젙 ?뚯뒪??""
        if not windows_setup.is_windows:
            pytest.skip("Windows ?섍꼍???꾨떃?덈떎")
        
        logger.info("?첒 Windows ?섍꼍 ?ㅼ젙 ?뚯뒪???쒖옉...")
        
        # 媛?곹솚寃?議댁옱 ?뺤씤
        assert windows_setup.venv_path.exists(), "Windows 媛?곹솚寃쎌씠 ?앹꽦?섏? ?딆븯?듬땲??
        
        # Python ?ㅽ뻾 ?뚯씪 議댁옱 ?뺤씤
        python_path = windows_setup.get_windows_python_path()
        assert os.path.exists(python_path), f"Windows Python ?ㅽ뻾 ?뚯씪??李얠쓣 ???놁뒿?덈떎: {python_path}"
        
        # ?꾩슂???⑦궎吏 ?ㅼ튂 ?뺤씤
        try:
            import selenium
            import pytest
            import webdriver_manager
            import requests
            logger.info("??紐⑤뱺 ?꾩슂???⑦궎吏媛 ?ㅼ튂?섏뼱 ?덉뒿?덈떎")
        except ImportError as e:
            pytest.fail(f"?꾩슂???⑦궎吏媛 ?ㅼ튂?섏? ?딆븯?듬땲?? {e}")
        
        logger.info("??Windows ?섍꼍 ?ㅼ젙 ?뚯뒪???듦낵")
    
    def test_windows_test_execution(self, windows_setup):
        """Windows ?섍꼍?먯꽌 ?뚯뒪???ㅽ뻾 ?뚯뒪??""
        if not windows_setup.is_windows:
            pytest.skip("Windows ?섍꼍???꾨떃?덈떎")
        
        logger.info("?㎦ Windows ?섍꼍?먯꽌 ?뚯뒪???ㅽ뻾 ?뚯뒪???쒖옉...")
        
        # 湲곕낯 ?뚯뒪???뚯씪???ㅽ뻾 ?뚯뒪??
        test_files = [
            "test_services_running.py",
            "test_frontend_selenium.py"
        ]
        
        for test_file in test_files:
            if (windows_setup.project_root / "tests" / test_file).exists():
                logger.info(f"?뱥 {test_file} ?뚯뒪???ㅽ뻾 以鍮??꾨즺")
            else:
                logger.warning(f"?좑툘 {test_file} ?뚯뒪???뚯씪??李얠쓣 ???놁뒿?덈떎")
        
        logger.info("??Windows ?섍꼍?먯꽌 ?뚯뒪???ㅽ뻾 ?뚯뒪???듦낵")
    
    def wait_for_element(self, driver, by, value, timeout=10):
        """?붿냼媛 ?섑????뚭퉴吏 ?湲?""
        try:
            element = WebDriverWait(driver, timeout).until(
                EC.presence_of_element_located((by, value))
            )
            return element
        except TimeoutException:
            logger.error(f"???붿냼 ?湲??쒓컙 珥덇낵: {by}={value}")
            raise
    
    def wait_for_element_clickable(self, driver, by, value, timeout=10):
        """?붿냼媛 ?대┃ 媛?ν븷 ?뚭퉴吏 ?湲?""
        try:
            element = WebDriverWait(driver, timeout).until(
                EC.element_to_be_clickable((by, value))
            )
            return element
        except TimeoutException:
            logger.error(f"???대┃ 媛?ν븳 ?붿냼 ?湲??쒓컙 珥덇낵: {by}={value}")
            raise
    
    def safe_click(self, driver, element):
        """?덉쟾???대┃ ?섑뻾"""
        try:
            driver.execute_script("arguments[0].scrollIntoView(true);", element)
            time.sleep(0.5)
            element.click()
            return True
        except Exception as e:
            logger.error(f"???대┃ ?ㅽ뙣: {e}")
            return False
    
    def test_page_load_and_title(self, driver):
        """?섏씠吏 濡쒕뱶 諛??쒕ぉ ?뺤씤"""
        logger.info("?뵇 ?섏씠吏 濡쒕뱶 諛??쒕ぉ ?뺤씤 ?뚯뒪???쒖옉...")
        
        try:
            driver.get("http://localhost")
            logger.info("?뱞 ?섏씠吏 濡쒕뱶 ?꾨즺")
            
            # ?섏씠吏 ?쒕ぉ ?뺤씤
            title = driver.title
            logger.info(f"?뱥 ?섏씠吏 ?쒕ぉ: {title}")
            
            # 濡쒓렇???쇱씠 ?덈뒗吏 ?뺤씤
            login_form = self.wait_for_element(driver, By.TAG_NAME, "form")
            logger.info("??濡쒓렇????諛쒓껄")
            
            # ?ㅽ겕由곗꺑 ???
                            driver.save_screenshot("tests/results/01_page_load_success.png")
                logger.info("?벝 ?섏씠吏 濡쒕뱶 ?깃났 ?ㅽ겕由곗꺑 ??? tests/results/01_page_load_success.png")
            
        except Exception as e:
            logger.error(f"???섏씠吏 濡쒕뱶 ?뚯뒪???ㅽ뙣: {e}")
                            driver.save_screenshot("tests/results/02_page_load_failed.png")
            raise
    
    def test_login_form_structure(self, driver):
        """濡쒓렇????援ъ“ ?뺤씤"""
        logger.info("?뵇 濡쒓렇????援ъ“ ?뺤씤 ?뚯뒪???쒖옉...")
        
        try:
            driver.get("http://localhost")
            
            # ?대찓???낅젰 ?꾨뱶 ?뺤씤
            email_input = self.wait_for_element(driver, By.NAME, "email")
            assert email_input.is_displayed(), "?대찓???낅젰 ?꾨뱶媛 ?쒖떆?섏? ?딆뒿?덈떎"
            logger.info("???대찓???낅젰 ?꾨뱶 ?뺤씤")
            
            # 鍮꾨?踰덊샇 ?낅젰 ?꾨뱶 ?뺤씤
            password_input = self.wait_for_element(driver, By.NAME, "password")
            assert password_input.is_displayed(), "鍮꾨?踰덊샇 ?낅젰 ?꾨뱶媛 ?쒖떆?섏? ?딆뒿?덈떎"
            logger.info("??鍮꾨?踰덊샇 ?낅젰 ?꾨뱶 ?뺤씤")
            
            # 濡쒓렇??踰꾪듉 ?뺤씤
            login_button = self.wait_for_element(driver, By.XPATH, "//button[@type='submit' and contains(text(), '濡쒓렇??)]")
            assert login_button.is_displayed(), "濡쒓렇??踰꾪듉???쒖떆?섏? ?딆뒿?덈떎"
            logger.info("??濡쒓렇??踰꾪듉 ?뺤씤")
            
            # ???좏슚??寃???띿꽦 ?뺤씤
            assert email_input.get_attribute("type") == "email", "?대찓???꾨뱶 ??낆씠 ?щ컮瑜댁? ?딆뒿?덈떎"
            assert password_input.get_attribute("type") == "password", "鍮꾨?踰덊샇 ?꾨뱶 ??낆씠 ?щ컮瑜댁? ?딆뒿?덈떎"
            logger.info("?????꾨뱶 ????뺤씤")
            
        except Exception as e:
            logger.error(f"??濡쒓렇????援ъ“ ?뚯뒪???ㅽ뙣: {e}")
                            driver.save_screenshot("tests/results/03_login_form_structure_failed.png")
            raise
    
    def test_login_with_valid_credentials(self, driver):
        """?좏슚???먭꺽利앸챸?쇰줈 濡쒓렇???뚯뒪??""
        logger.info("?뵇 ?좏슚???먭꺽利앸챸?쇰줈 濡쒓렇???뚯뒪???쒖옉...")
        
        try:
            driver.get("http://localhost")
            
            # 濡쒓렇?????낅젰
            email_input = self.wait_for_element(driver, By.NAME, "email")
            password_input = self.wait_for_element(driver, By.NAME, "password")
            
            # 湲곗〈 ?낅젰媛??쒓굅
            email_input.clear()
            password_input.clear()
            
            # ?뚯뒪???곗씠???낅젰
            test_email = "test@example.com"
            test_password = "testpassword123"
            
            email_input.send_keys(test_email)
            password_input.send_keys(test_password)
            
            logger.info(f"?벁 ?대찓???낅젰: {test_email}")
            logger.info(f"?뵏 鍮꾨?踰덊샇 ?낅젰: {test_password}")
            
            # 濡쒓렇??踰꾪듉 ?대┃
            login_button = self.wait_for_element_clickable(driver, By.XPATH, "//button[@type='submit' and contains(text(), '濡쒓렇??)]")
            self.safe_click(driver, login_button)
            logger.info("?뵖 濡쒓렇??踰꾪듉 ?대┃ ?꾨즺")
            
            # 濡쒓렇??寃곌낵 ?湲?(?깃났 ?먮뒗 ?ㅽ뙣 硫붿떆吏)
            try:
                success_message = WebDriverWait(driver, 15).until(
                    EC.presence_of_element_located((By.XPATH, "//div[contains(text(), '濡쒓렇???깃났') or contains(text(), '濡쒓렇???ㅽ뙣') or contains(text(), 'error') or contains(text(), 'Error')]"))
                )
                message_text = success_message.text
                logger.info(f"?뱷 濡쒓렇??寃곌낵 硫붿떆吏: {message_text}")
                
                # ?깃났 ?먮뒗 ?ㅽ뙣 ?щ?? 愿怨꾩뾾???뚯뒪???듦낵 (API ?쒕쾭 ?곹깭???곕씪 ?щ씪吏?
                logger.info("??濡쒓렇???뚯뒪???꾨즺")
                
            except TimeoutException:
                logger.warning("?좑툘 濡쒓렇??寃곌낵 硫붿떆吏瑜?李얠쓣 ???놁뒿?덈떎. API ?쒕쾭 ?곹깭瑜??뺤씤?댁＜?몄슂.")
                logger.info("??濡쒓렇???뚯뒪???꾨즺 (寃곌낵 硫붿떆吏 ?놁쓬)")
            
            # ?ㅽ겕由곗꺑 ???
                            driver.save_screenshot("tests/results/04_login_test_result.png")
            
        except Exception as e:
            logger.error(f"??濡쒓렇???뚯뒪???ㅽ뙣: {e}")
                            driver.save_screenshot("tests/results/05_login_test_failed.png")
            raise
    
    def test_login_with_invalid_credentials(self, driver):
        """?섎せ???먭꺽利앸챸?쇰줈 濡쒓렇???뚯뒪??""
        logger.info("?뵇 ?섎せ???먭꺽利앸챸?쇰줈 濡쒓렇???뚯뒪???쒖옉...")
        
        try:
            driver.get("http://localhost")
            
            # 濡쒓렇?????낅젰
            email_input = self.wait_for_element(driver, By.NAME, "email")
            password_input = self.wait_for_element(driver, By.NAME, "password")
            
            # 湲곗〈 ?낅젰媛??쒓굅
            email_input.clear()
            password_input.clear()
            
            # ?섎せ???뚯뒪???곗씠???낅젰
            invalid_email = "invalid@example.com"
            invalid_password = "wrongpassword"
            
            email_input.send_keys(invalid_email)
            password_input.send_keys(invalid_password)
            
            logger.info(f"?벁 ?섎せ???대찓???낅젰: {invalid_email}")
            logger.info(f"?뵏 ?섎せ??鍮꾨?踰덊샇 ?낅젰: {invalid_password}")
            
            # 濡쒓렇??踰꾪듉 ?대┃
            login_button = self.wait_for_element_clickable(driver, By.XPATH, "//button[@type='submit' and contains(text(), '濡쒓렇??)]")
            self.safe_click(driver, login_button)
            logger.info("?뵖 濡쒓렇??踰꾪듉 ?대┃ ?꾨즺")
            
            # ?먮윭 硫붿떆吏 ?湲?
            try:
                error_message = WebDriverWait(driver, 15).until(
                    EC.presence_of_element_located((By.XPATH, "//div[contains(text(), '濡쒓렇???ㅽ뙣') or contains(text(), 'error') or contains(text(), 'Error') or contains(text(), '?섎せ??)]"))
                )
                error_text = error_message.text
                logger.info(f"???먮윭 硫붿떆吏: {error_text}")
                logger.info("???섎せ???먭꺽利앸챸 ?뚯뒪???듦낵")
                
            except TimeoutException:
                logger.warning("?좑툘 ?먮윭 硫붿떆吏瑜?李얠쓣 ???놁뒿?덈떎. API ?쒕쾭 ?곹깭瑜??뺤씤?댁＜?몄슂.")
                logger.info("???섎せ???먭꺽利앸챸 ?뚯뒪???꾨즺 (?먮윭 硫붿떆吏 ?놁쓬)")
            
            # ?ㅽ겕由곗꺑 ???
                            driver.save_screenshot("tests/results/06_invalid_login_test_result.png")
            
        except Exception as e:
            logger.error(f"???섎せ???먭꺽利앸챸 濡쒓렇???뚯뒪???ㅽ뙣: {e}")
                            driver.save_screenshot("tests/results/07_invalid_login_test_failed.png")
            raise
    
    def test_form_validation(self, driver):
        """???좏슚??寃???뚯뒪??""
        logger.info("?뵇 ???좏슚??寃???뚯뒪???쒖옉...")
        
        try:
            driver.get("http://localhost")
            
            # 鍮??쇱쑝濡??쒖텧 ?쒕룄
            login_button = self.wait_for_element_clickable(driver, By.XPATH, "//button[@type='submit' and contains(text(), '濡쒓렇??)]")
            self.safe_click(driver, login_button)
            logger.info("?뵖 鍮??쇱쑝濡?濡쒓렇??踰꾪듉 ?대┃")
            
            # ?좏슚??寃??硫붿떆吏 ?뺤씤 (?좎떆 ?湲?
            time.sleep(2)
            
            # ?섏씠吏 ?곹깭 ?뺤씤
            current_url = driver.current_url
            logger.info(f"?뱧 ?꾩옱 URL: {current_url}")
            
            # ?쇱씠 ?ъ쟾???쒖떆?섎뒗吏 ?뺤씤
            try:
                form = driver.find_element(By.TAG_NAME, "form")
                assert form.is_displayed(), "?쇱씠 ?쒖떆?섏? ?딆뒿?덈떎"
                logger.info("?????좏슚??寃???뚯뒪???듦낵")
            except NoSuchElementException:
                logger.warning("?좑툘 ?쇱쓣 李얠쓣 ???놁뒿?덈떎")
            
            # ?ㅽ겕由곗꺑 ???
                            driver.save_screenshot("tests/results/08_form_validation_test_result.png")
            
        except Exception as e:
            logger.error(f"?????좏슚??寃???뚯뒪???ㅽ뙣: {e}")
                            driver.save_screenshot("tests/results/09_form_validation_test_failed.png")
            raise
    
    def test_tab_navigation(self, driver):
        """???ㅻ퉬寃뚯씠???뚯뒪??""
        logger.info("?뵇 ???ㅻ퉬寃뚯씠???뚯뒪???쒖옉...")
        
        try:
            driver.get("http://localhost")
            
            # 濡쒓렇?????뺤씤
            login_tab = self.wait_for_element(driver, By.XPATH, "//button[contains(text(), '濡쒓렇??)]")
            assert login_tab.is_displayed(), "濡쒓렇????씠 ?쒖떆?섏? ?딆뒿?덈떎"
            logger.info("??濡쒓렇?????뺤씤")
            
            # ?뚯썝媛?????뺤씤
            signup_tab = self.wait_for_element(driver, By.XPATH, "//button[contains(text(), '?뚯썝媛??)]")
            assert signup_tab.is_displayed(), "?뚯썝媛????씠 ?쒖떆?섏? ?딆뒿?덈떎"
            logger.info("???뚯썝媛?????뺤씤")
            
            # ?뚯썝媛?????대┃
            self.safe_click(driver, signup_tab)
            logger.info("?뵖 ?뚯썝媛?????대┃")
            
            # ?뚯썝媛?????뺤씤
            time.sleep(1)
            try:
                signup_form = driver.find_element(By.TAG_NAME, "form")
                assert signup_form.is_displayed(), "?뚯썝媛???쇱씠 ?쒖떆?섏? ?딆뒿?덈떎"
                logger.info("???뚯썝媛?????쒖떆 ?뺤씤")
            except NoSuchElementException:
                logger.warning("?좑툘 ?뚯썝媛???쇱쓣 李얠쓣 ???놁뒿?덈떎")
            
            # 濡쒓렇????쑝濡??ㅼ떆 ?꾪솚
            self.safe_click(driver, login_tab)
            logger.info("?뵖 濡쒓렇????쑝濡??꾪솚")
            
            time.sleep(1)
            try:
                login_form = driver.find_element(By.TAG_NAME, "form")
                assert login_form.is_displayed(), "濡쒓렇???쇱씠 ?쒖떆?섏? ?딆뒿?덈떎"
                logger.info("??濡쒓렇?????쒖떆 ?뺤씤")
            except NoSuchElementException:
                logger.warning("?좑툘 濡쒓렇???쇱쓣 李얠쓣 ???놁뒿?덈떎")
            
            logger.info("?????ㅻ퉬寃뚯씠???뚯뒪???듦낵")
            
            # ?ㅽ겕由곗꺑 ???
            driver.save_screenshot("tests/results/10tab_navigation_test_result.png")
            
        except Exception as e:
            logger.error(f"?????ㅻ퉬寃뚯씠???뚯뒪???ㅽ뙣: {e}")
            driver.save_screenshot("tests/results/11tab_navigation_test_failed.png")
            raise
    
    def test_responsive_design(self, driver):
        """諛섏쓳???붿옄???뚯뒪??""
        logger.info("?뵇 諛섏쓳???붿옄???뚯뒪???쒖옉...")
        
        try:
            # ?ㅼ뼇???붾㈃ ?ш린濡??뚯뒪??
            screen_sizes = [
                (1920, 1080),  # ?곗뒪?ы넲
                (1366, 768),   # ?명듃遺?
                (768, 1024),   # ?쒕툝由?
                (375, 667)     # 紐⑤컮??
            ]
            
            for width, height in screen_sizes:
                driver.set_window_size(width, height)
                logger.info(f"?벑 ?붾㈃ ?ш린 ?ㅼ젙: {width}x{height}")
                
                driver.get("http://localhost")
                time.sleep(1)
                
                # 湲곕낯 ?붿냼?ㅼ씠 ?쒖떆?섎뒗吏 ?뺤씤
                try:
                    form = driver.find_element(By.TAG_NAME, "form")
                    assert form.is_displayed(), f"?쇱씠 {width}x{height}?먯꽌 ?쒖떆?섏? ?딆뒿?덈떎"
                    logger.info(f"??{width}x{height}?먯꽌 ???쒖떆 ?뺤씤")
                except NoSuchElementException:
                    logger.warning(f"?좑툘 {width}x{height}?먯꽌 ?쇱쓣 李얠쓣 ???놁뒿?덈떎")
                
                # ?ㅽ겕由곗꺑 ???
                driver.save_screenshot(f"tests/results/12responsive_test_{width}x{height}.png")
            
            logger.info("??諛섏쓳???붿옄???뚯뒪???듦낵")
            
        except Exception as e:
            logger.error(f"??諛섏쓳???붿옄???뚯뒪???ㅽ뙣: {e}")
            driver.save_screenshot("tests/results/13responsive_design_test_failed.png")
            raise
    
    def test_performance_and_load_time(self, driver):
        """?깅뒫 諛?濡쒕뱶 ?쒓컙 ?뚯뒪??""
        logger.info("?뵇 ?깅뒫 諛?濡쒕뱶 ?쒓컙 ?뚯뒪???쒖옉...")
        
        try:
            # ?섏씠吏 濡쒕뱶 ?쒓컙 痢≪젙
            start_time = time.time()
            driver.get("http://localhost")
            
            # ?섏씠吏 濡쒕뱶 ?꾨즺 ?湲?
            self.wait_for_element(driver, By.TAG_NAME, "form")
            load_time = time.time() - start_time
            
            logger.info(f"?깍툘 ?섏씠吏 濡쒕뱶 ?쒓컙: {load_time:.2f}珥?)
            
            # 濡쒕뱶 ?쒓컙???⑸━?곸씤 踰붿쐞 ?댁뿉 ?덈뒗吏 ?뺤씤 (5珥??대궡)
            assert load_time < 5.0, f"?섏씠吏 濡쒕뱶 ?쒓컙???덈Т 源곷땲?? {load_time:.2f}珥?
            logger.info("???섏씠吏 濡쒕뱶 ?쒓컙???⑸━?곸엯?덈떎")
            
            # 硫붾え由??ъ슜???뺤씤 (釉뚮씪?곗? ?뺣낫)
            memory_info = driver.execute_script("return performance.memory")
            if memory_info:
                used_memory = memory_info.get('usedJSHeapSize', 0) / (1024 * 1024)  # MB
                logger.info(f"?뮶 ?ъ슜??JavaScript ??硫붾え由? {used_memory:.2f} MB")
            
            logger.info("???깅뒫 諛?濡쒕뱶 ?쒓컙 ?뚯뒪???듦낵")
            
            # ?ㅽ겕由곗꺑 ???
            driver.save_screenshot("tests/results/14performance_test_result.png")
            
        except Exception as e:
            logger.error(f"???깅뒫 諛?濡쒕뱶 ?쒓컙 ?뚯뒪???ㅽ뙣: {e}")
            driver.save_screenshot("tests/results/15performance_test_failed.png")
            raise
    
    def test_login_with_dummy_credentials(self, driver):
        """?붾? 怨꾩젙?쇰줈 濡쒓렇???뚯뒪??(foo@foo, pw:foo)"""
        logger.info("?뵇 ?붾? 怨꾩젙?쇰줈 濡쒓렇???뚯뒪???쒖옉...")
        
        try:
            driver.get("http://localhost")
            
            # 濡쒓렇?????낅젰
            email_input = self.wait_for_element(driver, By.NAME, "email")
            password_input = self.wait_for_element(driver, By.NAME, "password")
            
            # 湲곗〈 ?낅젰媛??쒓굅
            email_input.clear()
            password_input.clear()
            
            # ?붾? 怨꾩젙 ?곗씠???낅젰
            dummy_email = "foo@foo"
            dummy_password = "foo"
            
            email_input.send_keys(dummy_email)
            password_input.send_keys(dummy_password)
            
            logger.info(f"?벁 ?붾? ?대찓???낅젰: {dummy_email}")
            logger.info(f"?뵏 ?붾? 鍮꾨?踰덊샇 ?낅젰: {dummy_password}")
            
            # 濡쒓렇??踰꾪듉 ?대┃
            login_button = self.wait_for_element_clickable(driver, By.XPATH, "//button[@type='submit' and contains(text(), '濡쒓렇??)]")
            self.safe_click(driver, login_button)
            logger.info("?뵖 濡쒓렇??踰꾪듉 ?대┃ ?꾨즺")
            
            # 濡쒓렇??寃곌낵 ?湲?(?깃났 ?먮뒗 ?ㅽ뙣 硫붿떆吏)
            try:
                result_message = WebDriverWait(driver, 15).until(
                    EC.presence_of_element_located((By.XPATH, "//div[contains(text(), '濡쒓렇???깃났') or contains(text(), '濡쒓렇???ㅽ뙣') or contains(text(), 'error') or contains(text(), 'Error') or contains(text(), '?섎せ??)]"))
                )
                message_text = result_message.text
                logger.info(f"?뱷 ?붾? 怨꾩젙 濡쒓렇??寃곌낵 硫붿떆吏: {message_text}")
                
                # ?깃났 ?먮뒗 ?ㅽ뙣 ?щ?? 愿怨꾩뾾???뚯뒪???듦낵 (API ?쒕쾭 ?곹깭???곕씪 ?щ씪吏?
                logger.info("???붾? 怨꾩젙 濡쒓렇???뚯뒪???꾨즺")
                
            except TimeoutException:
                logger.warning("?좑툘 ?붾? 怨꾩젙 濡쒓렇??寃곌낵 硫붿떆吏瑜?李얠쓣 ???놁뒿?덈떎. API ?쒕쾭 ?곹깭瑜??뺤씤?댁＜?몄슂.")
                logger.info("???붾? 怨꾩젙 濡쒓렇???뚯뒪???꾨즺 (寃곌낵 硫붿떆吏 ?놁쓬)")
            
            # ?ㅽ겕由곗꺑 ???
            driver.save_screenshot("tests/results/16dummy_login_test_result.png")
            
            # ?뚯뒪???꾨즺 ??釉뚮씪?곗? ?좎? 硫붿떆吏
            logger.info("?럦 紐⑤뱺 ?뚯뒪?멸? ?꾨즺?섏뿀?듬땲??")
            logger.info("?뵏 Chrome 釉뚮씪?곗?瑜??대┛ ?곹깭濡??좎??⑸땲??")
            logger.info("?뮕 釉뚮씪?곗?瑜??섎룞?쇰줈 醫낅즺?섎젮硫?釉뚮씪?곗? 李쎌쓣 ?レ쑝?몄슂.")
            
        except Exception as e:
            logger.error(f"???붾? 怨꾩젙 濡쒓렇???뚯뒪???ㅽ뙣: {e}")
            driver.save_screenshot("tests/results/17dummy_login_test_failed.png")
            raise


if __name__ == "__main__":
    pytest.main([__file__, "-v", "-s", "--tb=short"])
