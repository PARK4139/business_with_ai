#!/usr/bin/env python3
"""
API 테스트 스크립트
모든 API 엔드포인트를 테스트하고 결과를 로그 파일에 저장
"""

import requests
import json
import time
from datetime import datetime
import os
from pathlib import Path

class APITester:
    def __init__(self):
        self.base_url = "http://localhost"
        self.results = []
        self.log_file = "logs/all_api_test.log"
        
        # 로그 디렉토리 생성
        Path("logs").mkdir(exist_ok=True)
        
    def log_result(self, endpoint, method, status_code, response_text, duration):
        """테스트 결과를 로그에 저장"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        log_entry = {
            "timestamp": timestamp,
            "endpoint": endpoint,
            "method": method,
            "status_code": status_code,
            "duration_ms": round(duration * 1000, 2),
            "response": response_text[:500] + "..." if len(response_text) > 500 else response_text
        }
        
        self.results.append(log_entry)
        
        # 실시간 로그 출력
        status_icon = "✅" if status_code == 200 else "❌"
        print(f"{status_icon} {method} {endpoint} - {status_code} ({duration:.2f}s)")
    
    def test_endpoint(self, endpoint, method="GET", data=None):
        """단일 엔드포인트 테스트"""
        url = f"{self.base_url}{endpoint}"
        
        try:
            start_time = time.time()
            
            if method == "GET":
                response = requests.get(url, timeout=10)
            elif method == "POST":
                response = requests.post(url, json=data, timeout=10)
            else:
                raise ValueError(f"지원하지 않는 HTTP 메서드: {method}")
            
            duration = time.time() - start_time
            
            self.log_result(
                endpoint=endpoint,
                method=method,
                status_code=response.status_code,
                response_text=response.text,
                duration=duration
            )
            
        except requests.exceptions.ConnectionError:
            self.log_result(
                endpoint=endpoint,
                method=method,
                status_code=0,
                response_text="Connection Error: 서비스가 실행되지 않았습니다.",
                duration=0
            )
        except Exception as e:
            self.log_result(
                endpoint=endpoint,
                method=method,
                status_code=0,
                response_text=f"Error: {str(e)}",
                duration=0
            )
    
    def run_all_tests(self):
        """모든 API 테스트 실행"""
        print("🧪 API 테스트 시작...")
        print("=" * 60)
        
        # API 엔드포인트 테스트
        api_endpoints = [
            ("/heal_base_hospital_worker/v1/api/ensure/login/", "POST"),
            ("/heal_base_hospital_worker/v1/api/ensure/user/profile/", "GET"),
            ("/heal_base_hospital_worker/v1/api/ensure/hospital/locations/", "GET"),
            ("/heal_base_hospital_worker/v1/api/ensure/hospital/location/101", "GET"),
        ]
        
        # Web 엔드포인트 테스트
        web_endpoints = [
            ("/heal_base_hospital_worker/v1/web/ensure/login/", "GET"),
            ("/heal_base_hospital_worker/v1/web/ensure/login-guide/", "GET"),
            ("/heal_base_hospital_worker/v1/web/ensure/login-via-google", "GET"),
            ("/heal_base_hospital_worker/v1/web/ensure/signup/", "GET"),
            ("/heal_base_hospital_worker/v1/web/ensure/signup-form-submit/", "POST"),
            ("/heal_base_hospital_worker/v1/web/ensure/signup-complete/", "GET"),
            ("/heal_base_hospital_worker/v1/web/ensure/logined/and/hospital-location-guided/101", "GET"),
        ]
        
        # 서비스 상태 확인
        health_endpoints = [
            ("/health", "GET"),
            ("/", "GET"),
        ]
        
        # API 엔드포인트 테스트
        print("📋 API 엔드포인트 테스트:")
        for endpoint, method in api_endpoints:
            self.test_endpoint(endpoint, method)
        
        print("\n📋 Web 엔드포인트 테스트:")
        for endpoint, method in web_endpoints:
            self.test_endpoint(endpoint, method)
        
        print("\n📋 서비스 상태 확인:")
        for endpoint, method in health_endpoints:
            self.test_endpoint(endpoint, method)
        
        # 결과 저장
        self.save_results()
        
        print("\n" + "=" * 60)
        print("✅ API 테스트 완료!")
        print(f"📄 결과 저장: {self.log_file}")
    
    def save_results(self):
        """테스트 결과를 로그 파일에 저장"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        with open(self.log_file, "w", encoding="utf-8") as f:
            f.write(f"API 테스트 결과 - {timestamp}\n")
            f.write("=" * 60 + "\n\n")
            
            # 요약 통계
            total_tests = len(self.results)
            successful_tests = len([r for r in self.results if r["status_code"] == 200])
            failed_tests = total_tests - successful_tests
            
            f.write(f"📊 테스트 요약:\n")
            f.write(f"   총 테스트: {total_tests}\n")
            f.write(f"   성공: {successful_tests}\n")
            f.write(f"   실패: {failed_tests}\n")
            f.write(f"   성공률: {(successful_tests/total_tests*100):.1f}%\n\n")
            
            # 상세 결과
            f.write("📋 상세 결과:\n")
            f.write("-" * 60 + "\n")
            
            for result in self.results:
                f.write(f"[{result['timestamp']}] {result['method']} {result['endpoint']}\n")
                f.write(f"   상태 코드: {result['status_code']}\n")
                f.write(f"   응답 시간: {result['duration_ms']}ms\n")
                f.write(f"   응답 내용: {result['response']}\n")
                f.write("-" * 60 + "\n")
        
        print(f"📊 테스트 요약: {successful_tests}/{total_tests} 성공 ({(successful_tests/total_tests*100):.1f}%)")

if __name__ == "__main__":
    tester = APITester()
    tester.run_all_tests()
