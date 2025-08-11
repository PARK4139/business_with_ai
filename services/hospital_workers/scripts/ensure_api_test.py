#!/usr/bin/env python3
"""
API ?ŒìŠ¤???¤í¬ë¦½íŠ¸
ëª¨ë“  API ?”ë“œ?¬ì¸?¸ë? ?ŒìŠ¤?¸í•˜ê³?ê²°ê³¼ë¥?ë¡œê·¸ ?Œì¼???€??
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
        
        # ë¡œê·¸ ?”ë ‰? ë¦¬ ?ì„±
        Path("logs").mkdir(exist_ok=True)
        
    def log_result(self, endpoint, method, status_code, response_text, duration):
        """?ŒìŠ¤??ê²°ê³¼ë¥?ë¡œê·¸???€??""
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
        
        # ?¤ì‹œê°?ë¡œê·¸ ì¶œë ¥
        status_icon = "?? if status_code == 200 else "??
        print(f"{status_icon} {method} {endpoint} - {status_code} ({duration:.2f}s)")
    
    def test_endpoint(self, endpoint, method="GET", data=None):
        """?¨ì¼ ?”ë“œ?¬ì¸???ŒìŠ¤??""
        url = f"{self.base_url}{endpoint}"
        
        try:
            start_time = time.time()
            
            if method == "GET":
                response = requests.get(url, timeout=10)
            elif method == "POST":
                response = requests.post(url, json=data, timeout=10)
            else:
                raise ValueError(f"ì§€?í•˜ì§€ ?ŠëŠ” HTTP ë©”ì„œ?? {method}")
            
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
                response_text="Connection Error: ?œë¹„?¤ê? ?¤í–‰?˜ì? ?Šì•˜?µë‹ˆ??",
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
        """ëª¨ë“  API ?ŒìŠ¤???¤í–‰"""
        print("?§ª API ?ŒìŠ¤???œì‘...")
        print("=" * 60)
        
        # API ?”ë“œ?¬ì¸???ŒìŠ¤??
        api_endpoints = [
            ("/heal_base_hospital_worker/v1/api/ensure/login/", "POST"),
            ("/heal_base_hospital_worker/v1/api/ensure/user/profile/", "GET"),
            ("/heal_base_hospital_worker/v1/api/ensure/hospital/locations/", "GET"),
            ("/heal_base_hospital_worker/v1/api/ensure/hospital/location/101", "GET"),
        ]
        
        # Web ?”ë“œ?¬ì¸???ŒìŠ¤??
        web_endpoints = [
            ("/heal_base_hospital_worker/v1/web/ensure/login/", "GET"),
            ("/heal_base_hospital_worker/v1/web/ensure/login-guide/", "GET"),
            ("/heal_base_hospital_worker/v1/web/ensure/login-via-google", "GET"),
            ("/heal_base_hospital_worker/v1/web/ensure/signup/", "GET"),
            ("/heal_base_hospital_worker/v1/web/ensure/signup-form-submit/", "POST"),
            ("/heal_base_hospital_worker/v1/web/ensure/signup-complete/", "GET"),
            ("/heal_base_hospital_worker/v1/web/ensure/logined/and/hospital-location-guided/101", "GET"),
        ]
        
        # ?œë¹„???íƒœ ?•ì¸
        health_endpoints = [
            ("/health", "GET"),
            ("/", "GET"),
        ]
        
        # API ?”ë“œ?¬ì¸???ŒìŠ¤??
        print("?“‹ API ?”ë“œ?¬ì¸???ŒìŠ¤??")
        for endpoint, method in api_endpoints:
            self.test_endpoint(endpoint, method)
        
        print("\n?“‹ Web ?”ë“œ?¬ì¸???ŒìŠ¤??")
        for endpoint, method in web_endpoints:
            self.test_endpoint(endpoint, method)
        
        print("\n?“‹ ?œë¹„???íƒœ ?•ì¸:")
        for endpoint, method in health_endpoints:
            self.test_endpoint(endpoint, method)
        
        # ê²°ê³¼ ?€??
        self.save_results()
        
        print("\n" + "=" * 60)
        print("??API ?ŒìŠ¤???„ë£Œ!")
        print(f"?“„ ê²°ê³¼ ?€?? {self.log_file}")
    
    def save_results(self):
        """?ŒìŠ¤??ê²°ê³¼ë¥?ë¡œê·¸ ?Œì¼???€??""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        with open(self.log_file, "w", encoding="utf-8") as f:
            f.write(f"API ?ŒìŠ¤??ê²°ê³¼ - {timestamp}\n")
            f.write("=" * 60 + "\n\n")
            
            # ?”ì•½ ?µê³„
            total_tests = len(self.results)
            successful_tests = len([r for r in self.results if r["status_code"] == 200])
            failed_tests = total_tests - successful_tests
            
            f.write(f"?“Š ?ŒìŠ¤???”ì•½:\n")
            f.write(f"   ì´??ŒìŠ¤?? {total_tests}\n")
            f.write(f"   ?±ê³µ: {successful_tests}\n")
            f.write(f"   ?¤íŒ¨: {failed_tests}\n")
            f.write(f"   ?±ê³µë¥? {(successful_tests/total_tests*100):.1f}%\n\n")
            
            # ?ì„¸ ê²°ê³¼
            f.write("?“‹ ?ì„¸ ê²°ê³¼:\n")
            f.write("-" * 60 + "\n")
            
            for result in self.results:
                f.write(f"[{result['timestamp']}] {result['method']} {result['endpoint']}\n")
                f.write(f"   ?íƒœ ì½”ë“œ: {result['status_code']}\n")
                f.write(f"   ?‘ë‹µ ?œê°„: {result['duration_ms']}ms\n")
                f.write(f"   ?‘ë‹µ ?´ìš©: {result['response']}\n")
                f.write("-" * 60 + "\n")
        
        print(f"?“Š ?ŒìŠ¤???”ì•½: {successful_tests}/{total_tests} ?±ê³µ ({(successful_tests/total_tests*100):.1f}%)")

if __name__ == "__main__":
    tester = APITester()
    tester.run_all_tests()
