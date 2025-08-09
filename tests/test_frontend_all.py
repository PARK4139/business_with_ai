#!/usr/bin/env python3
"""
프론트엔드 종합 테스트 스크립트
동적으로 URL과 포트를 할당하여 프론트엔드 서비스 테스트
"""

import requests
import time
import json
import subprocess
import sys
import os
import platform
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from pathlib import Path
import logging

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('frontend_test.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class ServiceConfig:
    """서비스 설정 정보"""
    name: str
    default_port: int
    health_endpoint: str
    expected_status: int = 200
    timeout: int = 10

@dataclass
class TestResult:
    """테스트 결과"""
    service_name: str
    url: str
    status: str
    response_time: float
    details: str
    timestamp: str

class FrontendTester:
    """프론트엔드 테스터 클래스"""
    
    def __init__(self):
        self.base_url = "http://localhost"
        self.services = {
            "page-server": ServiceConfig(
                name="page-server",
                default_port=5173,
                health_endpoint="/",
                expected_status=200,
                timeout=30  # Next.js 컴파일 시간을 고려하여 30초로 증가
            ),
            "api-server": ServiceConfig(
                name="api-server", 
                default_port=8002,
                health_endpoint="/docs",
                expected_status=200
            ),
            "nginx": ServiceConfig(
                name="nginx",
                default_port=80,
                health_endpoint="/",
                expected_status=200
            )
        }
        self.test_results: List[TestResult] = []
        self.is_wsl = self._detect_wsl()
        self.available_urls = []
        
    def _detect_wsl(self) -> bool:
        """WSL 환경 감지"""
        try:
            with open('/proc/version', 'r') as f:
                version_info = f.read().lower()
                return 'microsoft' in version_info or 'wsl' in version_info
        except:
            return False
    
    def _get_windows_chrome_path(self) -> Optional[str]:
        """Windows Chrome 경로 찾기"""
        chrome_paths = [
            r"C:\Program Files\Google\Chrome\Application\chrome.exe",
            r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
            os.path.expanduser(r"~\AppData\Local\Google\Chrome\Application\chrome.exe")
        ]
        
        for path in chrome_paths:
            if os.path.exists(path):
                return path
        return None
    
    def _open_windows_chrome(self, urls: List[str]):
        """Windows Chrome으로 URL들 열기"""
        # WSL에서 Windows 명령어 사용
        try:
            # Windows Chrome을 직접 실행
            chrome_cmd = f'start chrome {" ".join(urls)}'
            subprocess.run(['cmd.exe', '/c', chrome_cmd], shell=True, timeout=10)
            print(f"🚀 Windows Chrome으로 {len(urls)}개 URL을 열었습니다!")
            print(f"   🔧 사용된 명령어: {chrome_cmd}")
            print("   💡 Chrome이 실행되지 않으면 수동으로 URL을 복사하여 테스트하세요.")
        except subprocess.TimeoutExpired:
            print("⏰ Chrome 실행 시간 초과")
            print("   💡 수동으로 다음 URL들을 열어주세요:")
            for url in urls:
                print(f"      🌐 {url}")
        except Exception as e:
            print(f"❌ Windows Chrome 실행 실패: {e}")
            print("   💡 대안 방법:")
            print("   1. Windows에서 직접 실행:")
            print(f"      start chrome {' '.join(urls)}")
            print("   2. 수동으로 다음 URL들을 열어주세요:")
            for url in urls:
                print(f"      🌐 {url}")
    
    def _suggest_linux_browsers(self, urls: List[str]):
        """Linux 환경에서 브라우저 제안"""
        print("\n🐧 Linux 환경에서 테스트할 수 있는 방법:")
        print("=" * 60)
        
        # 사용 가능한 브라우저 확인
        browsers = [
            ("firefox", "Firefox"),
            ("google-chrome", "Google Chrome"),
            ("chromium-browser", "Chromium"),
            ("brave-browser", "Brave Browser"),
            ("opera", "Opera")
        ]
        
        available_browsers = []
        for cmd, name in browsers:
            try:
                result = subprocess.run(["which", cmd], capture_output=True, text=True)
                if result.returncode == 0:
                    available_browsers.append((cmd, name))
            except:
                continue
        
        if available_browsers:
            print("✅ 사용 가능한 브라우저:")
            for i, (cmd, name) in enumerate(available_browsers, 1):
                print(f"   {i}. {name} ({cmd})")
            
            print("\n🔧 브라우저로 URL 열기:")
            for cmd, name in available_browsers:
                print(f"   {cmd} {' '.join(urls)}")
        else:
            print("⚠️  설치된 브라우저가 없습니다.")
            print("   다음 명령어로 브라우저를 설치할 수 있습니다:")
            print("   sudo apt update && sudo apt install firefox")
        
        print("\n🌐 테스트할 URL들:")
        for i, url in enumerate(urls, 1):
            print(f"   {i}. {url}")
        
        print("\n💡 WSL 환경에서 Windows Chrome 사용하려면:")
        print("   Windows에서 다음 명령어를 실행하세요:")
        print("   start chrome " + " ".join(urls))
        
        print("=" * 60)
    
    def print_test_urls(self):
        """테스트 가능한 URL들을 출력하고 브라우저로 열기"""
        if not self.available_urls:
            print("⚠️  테스트할 URL이 없습니다.")
            return
        
        print("\n" + "="*80)
        print("🌐 프론트엔드 테스트 URL")
        print("="*80)
        
        for i, url in enumerate(self.available_urls, 1):
            print(f"{i:2d}. {url}")
        
        print("="*80)
        
        if self.is_wsl:
            print("🪟 WSL 환경 감지됨 - Windows Chrome으로 자동 열기 시도...")
            self._open_windows_chrome(self.available_urls)
        else:
            print("🐧 Linux 환경 감지됨")
            self._suggest_linux_browsers(self.available_urls)
    
    def get_docker_services(self) -> Dict[str, int]:
        """Docker 실행 중인 서비스의 포트 정보 가져오기"""
        try:
            result = subprocess.run(
                ["docker", "ps", "--format", "{{.Names}}\t{{.Ports}}"],
                capture_output=True, text=True, timeout=10
            )
            
            if result.returncode != 0:
                logger.warning("Docker 명령어 실행 실패")
                return {}
                
            services = {}
            for line in result.stdout.strip().split('\n'):
                if line:
                    parts = line.split('\t')
                    if len(parts) == 2:
                        name = parts[0]
                        ports = parts[1]
                        
                        # 포트 정보 파싱 (예: "0.0.0.0:5173->5173/tcp")
                        if '->' in ports:
                            host_port = ports.split('->')[0].split(':')[1]
                            if host_port.isdigit():
                                services[name] = int(host_port)
                                
            logger.info(f"발견된 Docker 서비스: {services}")
            return services
            
        except Exception as e:
            logger.error(f"Docker 서비스 정보 가져오기 실패: {e}")
            return {}
    
    def test_service_health(self, service_name: str, port: int, config: ServiceConfig) -> TestResult:
        """개별 서비스 헬스 체크"""
        url = f"{self.base_url}:{port}{config.health_endpoint}"
        start_time = time.time()
        
        try:
            response = requests.get(
                url, 
                timeout=config.timeout,
                headers={'User-Agent': 'FrontendTester/1.0'}
            )
            
            response_time = time.time() - start_time
            
            if response.status_code == config.expected_status:
                status = "SUCCESS"
                details = f"상태 코드: {response.status_code}, 응답 크기: {len(response.content)} bytes"
            else:
                status = "FAILED"
                details = f"예상 상태 코드: {config.expected_status}, 실제: {response.status_code}"
                
        except requests.exceptions.Timeout:
            status = "TIMEOUT"
            details = f"요청 시간 초과 ({config.timeout}초)"
            response_time = config.timeout
            
        except requests.exceptions.ConnectionError:
            status = "CONNECTION_ERROR"
            details = "연결 실패 - 서비스가 실행 중이지 않음"
            response_time = 0
            
        except Exception as e:
            status = "ERROR"
            details = f"예상치 못한 오류: {str(e)}"
            response_time = 0
            
        return TestResult(
            service_name=service_name,
            url=url,
            status=status,
            response_time=response_time,
            details=details,
            timestamp=time.strftime("%Y-%m-%d %H:%M:%S")
        )
    
    def test_page_server_functionality(self, port: int) -> List[TestResult]:
        """Page Server 기능 테스트"""
        results = []
        base_url = f"{self.base_url}:{port}"
        
        # 기본 페이지 로드 테스트 (재시도 로직 포함)
        max_retries = 3
        retry_delay = 5
        
        for attempt in range(max_retries):
            try:
                logger.info(f"Page Server 테스트 시도 {attempt + 1}/{max_retries}")
                response = requests.get(f"{base_url}/", timeout=30)  # timeout 증가
                
                if response.status_code == 200:
                    results.append(TestResult(
                        service_name="page-server-basic",
                        url=f"{base_url}/",
                        status="SUCCESS",
                        response_time=0,
                        details=f"기본 페이지 로드 성공 (시도 {attempt + 1})",
                        timestamp=time.strftime("%Y-%m-%d %H:%M:%S")
                    ))
                    
                    # HTML 내용 검증
                    if "Next.js" in response.text or "React" in response.text:
                        results.append(TestResult(
                            service_name="page-server-content",
                            url=f"{base_url}/",
                            status="SUCCESS", 
                            response_time=0,
                            details="Next.js/React 프레임워크 감지됨",
                            timestamp=time.strftime("%Y-%m-%d %H:%M:%S")
                        ))
                    else:
                        results.append(TestResult(
                            service_name="page-server-content",
                            url=f"{base_url}/",
                            status="WARNING",
                            response_time=0,
                            details="프레임워크 감지되지 않음",
                            timestamp=time.strftime("%Y-%m-%d %H:%M:%S")
                        ))
                    
                    # 성공하면 재시도 중단
                    break
                    
                else:
                    if attempt == max_retries - 1:  # 마지막 시도
                        results.append(TestResult(
                            service_name="page-server-basic",
                            url=f"{base_url}/",
                            status="FAILED",
                            response_time=0,
                            details=f"상태 코드: {response.status_code} (최종 시도)",
                            timestamp=time.strftime("%Y-%m-%d %H:%M:%S")
                        ))
                    else:
                        logger.warning(f"Page Server 응답 실패 (시도 {attempt + 1}): {response.status_code}")
                        time.sleep(retry_delay)
                        
            except requests.exceptions.Timeout:
                if attempt == max_retries - 1:  # 마지막 시도
                    results.append(TestResult(
                        service_name="page-server-basic",
                        url=f"{base_url}/",
                        status="TIMEOUT",
                        response_time=30,
                        details=f"요청 시간 초과 (30초, 최종 시도)",
                        timestamp=time.strftime("%Y-%m-%d %H:%M:%S")
                    ))
                else:
                    logger.warning(f"Page Server timeout (시도 {attempt + 1}), {retry_delay}초 후 재시도")
                    time.sleep(retry_delay)
                    
            except Exception as e:
                if attempt == max_retries - 1:  # 마지막 시도
                    results.append(TestResult(
                        service_name="page-server-basic",
                        url=f"{base_url}/",
                        status="ERROR",
                        response_time=0,
                        details=f"테스트 실패 (최종 시도): {str(e)}",
                        timestamp=time.strftime("%Y-%m-%d %H:%M:%S")
                    ))
                else:
                    logger.warning(f"Page Server 오류 (시도 {attempt + 1}): {str(e)}, {retry_delay}초 후 재시도")
                    time.sleep(retry_delay)
            
        return results
    
    def test_api_server_functionality(self, port: int) -> List[TestResult]:
        """API Server 기능 테스트"""
        results = []
        base_url = f"{self.base_url}:{port}"
        
        # Swagger 문서 접근 테스트
        try:
            response = requests.get(f"{base_url}/docs", timeout=10)
            if response.status_code == 200:
                results.append(TestResult(
                    service_name="api-server-docs",
                    url=f"{base_url}/docs",
                    status="SUCCESS",
                    response_time=0,
                    details="API 문서 접근 성공",
                    timestamp=time.strftime("%Y-%m-%d %H:%M:%S")
                ))
            else:
                results.append(TestResult(
                    service_name="api-server-docs",
                    url=f"{base_url}/docs",
                    status="FAILED",
                    response_time=0,
                    details=f"API 문서 접근 실패: {response.status_code}",
                    timestamp=time.strftime("%Y-%m-%d %H:%M:%S")
                ))
        except Exception as e:
            results.append(TestResult(
                service_name="api-server-docs",
                url=f"{base_url}/docs",
                status="ERROR",
                response_time=0,
                details=f"API 문서 테스트 실패: {str(e)}",
                timestamp=time.strftime("%Y-%m-%d %H:%M:%S")
            ))
            
        return results
    
    def run_all_tests(self) -> List[TestResult]:
        """모든 테스트 실행"""
        logger.info("프론트엔드 종합 테스트 시작")
        
        # Docker 서비스 정보 가져오기
        docker_services = self.get_docker_services()
        logger.info(f"실행 중인 Docker 서비스: {docker_services}")
        
        # 테스트 가능한 URL 수집
        self.available_urls = []
        
        # 기본 헬스 체크
        for service_name, config in self.services.items():
            # Docker에서 실제 포트 찾기
            actual_port = None
            for docker_name, port in docker_services.items():
                if service_name in docker_name:
                    actual_port = port
                    break
            
            # 기본 포트 사용
            if actual_port is None:
                actual_port = config.default_port
                logger.warning(f"{service_name}: Docker 포트를 찾을 수 없어 기본 포트 {actual_port} 사용")
            
            # URL 수집
            url = f"{self.base_url}:{actual_port}{config.health_endpoint}"
            if url not in self.available_urls:
                self.available_urls.append(url)
            
            # 서비스 테스트
            result = self.test_service_health(service_name, actual_port, config)
            self.test_results.append(result)
            
            # 추가 기능 테스트
            if service_name == "page-server":
                self.test_results.extend(self.test_page_server_functionality(actual_port))
            elif service_name == "api-server":
                self.test_results.extend(self.test_api_server_functionality(actual_port))
        
        logger.info("모든 테스트 완료")
        return self.test_results
    
    def print_results(self):
        """테스트 결과 출력"""
        print("\n" + "="*80)
        print("🏥 프론트엔드 종합 테스트 결과")
        print("="*80)
        
        success_count = sum(1 for r in self.test_results if r.status == "SUCCESS")
        total_count = len(self.test_results)
        
        print(f"📊 전체 테스트: {total_count}개")
        print(f"✅ 성공: {success_count}개")
        print(f"❌ 실패: {total_count - success_count}개")
        print(f"📈 성공률: {(success_count/total_count*100):.1f}%")
        print()
        
        # 서비스별 결과 그룹화
        service_groups = {}
        for result in self.test_results:
            if result.service_name not in service_groups:
                service_groups[result.service_name] = []
            service_groups[result.service_name].append(result)
        
        for service_name, results in service_groups.items():
            print(f"🔍 {service_name.upper()}")
            print("-" * 50)
            
            for result in results:
                status_icon = {
                    "SUCCESS": "✅",
                    "FAILED": "❌", 
                    "ERROR": "💥",
                    "TIMEOUT": "⏰",
                    "CONNECTION_ERROR": "🔌",
                    "WARNING": "⚠️"
                }.get(result.status, "❓")
                
                print(f"{status_icon} {result.url}")
                print(f"   상태: {result.status}")
                print(f"   응답시간: {result.response_time:.3f}초")
                print(f"   상세: {result.details}")
                print(f"   시간: {result.timestamp}")
                print()
        
        print("="*80)
    
    def save_results_to_file(self, filename: str = "tests/frontend_test_results.json"):
        """테스트 결과를 JSON 파일로 저장"""
        try:
            results_data = []
            for result in self.test_results:
                results_data.append({
                    "service_name": result.service_name,
                    "url": result.url,
                    "status": result.status,
                    "response_time": result.response_time,
                    "details": result.details,
                    "timestamp": result.timestamp
                })
            
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(results_data, f, ensure_ascii=False, indent=2)
            
            logger.info(f"테스트 결과가 {filename}에 저장되었습니다.")
            
        except Exception as e:
            logger.error(f"결과 저장 실패: {e}")

def main():
    """메인 함수"""
    print("🚀 프론트엔드 종합 테스트 시작")
    print("="*50)
    
    # 테스터 생성 및 실행
    tester = FrontendTester()
    results = tester.run_all_tests()
    
    # 결과 출력
    tester.print_results()
    
    # 테스트 URL 출력 및 브라우저로 열기
    tester.print_test_urls()
    
    # 결과 저장
    tester.save_results_to_file()
    
    # 종료 코드 결정
    success_count = sum(1 for r in results if r.status == "SUCCESS")
    total_count = len(results)
    
    if success_count == total_count:
        print("🎉 모든 테스트가 성공했습니다!")
        print("🌐 위의 URL들을 브라우저에서 열어 프론트엔드를 테스트해보세요!")
        sys.exit(0)
    else:
        print(f"⚠️  {total_count - success_count}개 테스트가 실패했습니다.")
        sys.exit(1)

if __name__ == "__main__":
    main()
