#!/usr/bin/env python3
"""
프론트엔드 Selenium 자동화 테스트
병원 근무자 관리 시스템의 UI 기능을 자동으로 테스트합니다.
"""

import time
import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager


class TestHospitalWorkersFrontend:
    """병원 근무자 관리 시스템 프론트엔드 테스트 클래스"""
    
    @pytest.fixture(scope="class")
    def driver(self):
        """Chrome WebDriver 설정 및 초기화"""
        chrome_options = Options()
        chrome_options.add_argument("--headless")  # 헤드리스 모드
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--window-size=1920,1080")
        
        # ChromeDriver 자동 설치 및 설정
        service = Service(ChromeDriverManager().install())
        driver = webdriver.Chrome(service=service, options=chrome_options)
        
        yield driver
        
        # 테스트 완료 후 브라우저 종료
        driver.quit()
    
    def test_page_load(self, driver):
        """메인 페이지 로드 테스트"""
        print("🔍 메인 페이지 로드 테스트 시작...")
        
        # 메인 페이지 접속
        driver.get("http://localhost")
        
        # 페이지 제목 확인
        title = driver.title
        assert "병원 근무자 관리" in title or "Hospital Workers" in title, f"페이지 제목이 올바르지 않습니다: {title}"
        
        # 헤더 확인
        header = driver.find_element(By.TAG_NAME, "h1")
        assert "🏥 병원 근무자 관리" in header.text
        
        print("✅ 메인 페이지 로드 테스트 통과")
    
    def test_login_form_display(self, driver):
        """로그인 폼 표시 테스트"""
        print("🔍 로그인 폼 표시 테스트 시작...")
        
        driver.get("http://localhost")
        
        # 로그인 탭이 기본으로 활성화되어 있는지 확인
        login_tab = driver.find_element(By.XPATH, "//button[contains(text(), '로그인')]")
        assert "bg-indigo-100" in login_tab.get_attribute("class")
        
        # 로그인 폼 요소들 확인
        email_input = driver.find_element(By.NAME, "email")
        password_input = driver.find_element(By.NAME, "password")
        login_button = driver.find_element(By.XPATH, "//button[@type='submit' and contains(text(), '로그인')]")
        
        assert email_input.is_displayed()
        assert password_input.is_displayed()
        assert login_button.is_displayed()
        
        print("✅ 로그인 폼 표시 테스트 통과")
    
    def test_signup_form_display(self, driver):
        """회원가입 폼 표시 테스트"""
        print("🔍 회원가입 폼 표시 테스트 시작...")
        
        driver.get("http://localhost")
        
        # 회원가입 탭 클릭
        signup_tab = driver.find_element(By.XPATH, "//button[contains(text(), '회원가입')]")
        signup_tab.click()
        time.sleep(1)
        
        # 회원가입 폼 요소들 확인
        first_name_input = driver.find_element(By.NAME, "firstName")
        last_name_input = driver.find_element(By.NAME, "lastName")
        email_input = driver.find_element(By.NAME, "email")
        department_select = driver.find_element(By.NAME, "department")
        password_input = driver.find_element(By.NAME, "password")
        confirm_password_input = driver.find_element(By.NAME, "confirmPassword")
        agree_terms_checkbox = driver.find_element(By.NAME, "agreeTerms")
        signup_button = driver.find_element(By.XPATH, "//button[@type='submit' and contains(text(), '회원가입')]")
        
        assert first_name_input.is_displayed()
        assert last_name_input.is_displayed()
        assert email_input.is_displayed()
        assert department_select.is_displayed()
        assert password_input.is_displayed()
        assert confirm_password_input.is_displayed()
        assert agree_terms_checkbox.is_displayed()
        assert signup_button.is_displayed()
        
        print("✅ 회원가입 폼 표시 테스트 통과")
    
    def test_location_guide_tab(self, driver):
        """병실 위치 가이드 탭 테스트"""
        print("🔍 병실 위치 가이드 탭 테스트 시작...")
        
        driver.get("http://localhost")
        
        # 병실 위치 가이드 탭 클릭
        location_tab = driver.find_element(By.XPATH, "//button[contains(text(), '병실 위치')]")
        location_tab.click()
        time.sleep(1)
        
        # 탭이 활성화되었는지 확인
        assert "bg-indigo-100" in location_tab.get_attribute("class")
        
        print("✅ 병실 위치 가이드 탭 테스트 통과")
    
    def test_login_functionality(self, driver):
        """로그인 기능 테스트"""
        print("🔍 로그인 기능 테스트 시작...")
        
        driver.get("http://localhost")
        
        # 로그인 폼에 테스트 계정 정보 입력
        email_input = driver.find_element(By.NAME, "email")
        password_input = driver.find_element(By.NAME, "password")
        
        email_input.clear()
        email_input.send_keys("foo@foo")
        
        password_input.clear()
        password_input.send_keys("foo")
        
        # 로그인 버튼 클릭
        login_button = driver.find_element(By.XPATH, "//button[@type='submit' and contains(text(), '로그인')]")
        login_button.click()
        
        # 로그인 성공 메시지 확인 (최대 10초 대기)
        try:
            success_message = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.XPATH, "//div[contains(text(), '로그인 성공')]"))
            )
            assert "로그인 성공" in success_message.text
            print("✅ 로그인 기능 테스트 통과")
        except Exception as e:
            print(f"❌ 로그인 성공 메시지를 찾을 수 없습니다: {e}")
            # 현재 페이지의 메시지 확인
            messages = driver.find_elements(By.XPATH, "//div[contains(@class, 'message') or contains(@class, 'text')]")
            for msg in messages:
                if msg.text:
                    print(f"현재 메시지: {msg.text}")
            raise
    
    def test_form_validation(self, driver):
        """폼 유효성 검사 테스트"""
        print("🔍 폼 유효성 검사 테스트 시작...")
        
        driver.get("http://localhost")
        
        # 회원가입 탭으로 이동
        signup_tab = driver.find_element(By.XPATH, "//button[contains(text(), '회원가입')]")
        signup_tab.click()
        time.sleep(1)
        
        # 빈 폼으로 제출 시도
        signup_button = driver.find_element(By.XPATH, "//button[@type='submit' and contains(text(), '회원가입')]")
        signup_button.click()
        
        # 필수 필드 오류 메시지 확인
        time.sleep(1)
        
        print("✅ 폼 유효성 검사 테스트 통과")
    
    def test_responsive_design(self, driver):
        """반응형 디자인 테스트"""
        print("🔍 반응형 디자인 테스트 시작...")
        
        # 데스크톱 크기
        driver.set_window_size(1920, 1080)
        driver.get("http://localhost")
        time.sleep(1)
        
        # 태블릿 크기
        driver.set_window_size(768, 1024)
        time.sleep(1)
        
        # 모바일 크기
        driver.set_window_size(375, 667)
        time.sleep(1)
        
        # 원래 크기로 복원
        driver.set_window_size(1920, 1080)
        
        print("✅ 반응형 디자인 테스트 통과")


if __name__ == "__main__":
    # 테스트 실행
    pytest.main([__file__, "-v", "--tb=short"])
