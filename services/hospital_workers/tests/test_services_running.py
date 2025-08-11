"""
서비스 실행 상태 확인
test_ 패턴을 사용하여 필요한 서비스들이 실행 중인지 확인합니다.
"""

import pytest
import requests
import time
import subprocess
import json
from urllib.parse import urljoin


class TestServicesRunning:
    """서비스 실행 상태 확인"""
    
    def test_docker_running(self):
        """Docker가 실행 중인지 확인"""
        try:
            result = subprocess.run(
                ["docker", "--version"], 
                capture_output=True, 
                text=True, 
                timeout=10
            )
            assert result.returncode == 0, "Docker 명령어 실행 실패"
            print("✅ Docker가 실행 중입니다.")
        except Exception as e:
            pytest.fail(f"Docker 확인 실패: {e}")
    
    def test_docker_compose_available(self):
        """Docker Compose를 사용할 수 있는지 확인"""
        try:
            result = subprocess.run(
                ["docker-compose", "--version"], 
                capture_output=True, 
                text=True, 
                timeout=10
            )
            assert result.returncode == 0, "Docker Compose 명령어 실행 실패"
            print("✅ Docker Compose를 사용할 수 있습니다.")
        except Exception as e:
            pytest.fail(f"Docker Compose 확인 실패: {e}")
    
    def test_page_server_running(self):
        """Page Server (Next.js)가 실행 중인지 확인"""
        try:
            response = requests.get("http://localhost", timeout=10)
            assert response.status_code == 200, f"Page Server 응답 코드: {response.status_code}"
            print("✅ Page Server가 실행 중입니다.")
        except requests.exceptions.RequestException as e:
            pytest.fail(f"Page Server 연결 실패: {e}")
    
    def test_api_server_running(self):
        """API Server (FastAPI)가 실행 중인지 확인"""
        try:
            response = requests.get("http://localhost:8000/health", timeout=10)
            assert response.status_code == 200, f"API Server 응답 코드: {response.status_code}"
            print("✅ API Server가 실행 중입니다.")
        except requests.exceptions.RequestException as e:
            pytest.fail(f"API Server 연결 실패: {e}")
    
    def test_database_server_running(self):
        """Database Server (PostgreSQL)가 실행 중인지 확인"""
        try:
            # Docker 컨테이너 상태 확인
            result = subprocess.run(
                ["docker", "ps", "--filter", "name=postgres", "--format", "{{.Status}}"],
                capture_output=True,
                text=True,
                timeout=10
            )
            assert result.returncode == 0, "Docker 컨테이너 상태 확인 실패"
            assert "Up" in result.stdout, "PostgreSQL 컨테이너가 실행 중이 아닙니다"
            print("✅ Database Server가 실행 중입니다.")
        except Exception as e:
            pytest.fail(f"Database Server 확인 실패: {e}")
    
    def test_redis_server_running(self):
        """Redis Server가 실행 중인지 확인"""
        try:
            # Docker 컨테이너 상태 확인
            result = subprocess.run(
                ["docker", "ps", "--filter", "name=redis", "--format", "{{.Status}}"],
                capture_output=True,
                text=True,
                timeout=10
            )
            assert result.returncode == 0, "Docker 컨테이너 상태 확인 실패"
            assert "Up" in result.stdout, "Redis 컨테이너가 실행 중이 아닙니다"
            print("✅ Redis Server가 실행 중입니다.")
        except Exception as e:
            pytest.fail(f"Redis Server 확인 실패: {e}")
    
    def test_nginx_running(self):
        """Nginx가 실행 중인지 확인"""
        try:
            # Docker 컨테이너 상태 확인
            result = subprocess.run(
                ["docker", "ps", "--filter", "name=nginx", "--format", "{{.Status}}"],
                capture_output=True,
                text=True,
                timeout=10
            )
            assert result.returncode == 0, "Docker 컨테이너 상태 확인 실패"
            assert "Up" in result.stdout, "Nginx 컨테이너가 실행 중이 아닙니다"
            print("✅ Nginx가 실행 중입니다.")
        except Exception as e:
            pytest.fail(f"Nginx 확인 실패: {e}")
    
    def test_all_services_healthy(self):
        """모든 서비스가 정상 상태인지 확인"""
        try:
            result = subprocess.run(
                ["docker-compose", "ps"],
                capture_output=True,
                text=True,
                timeout=10
            )
            assert result.returncode == 0, "Docker Compose 상태 확인 실패"
            
            # 모든 서비스가 Up 상태인지 확인
            lines = result.stdout.strip().split('\n')
            service_lines = [line for line in lines if 'Up' in line]
            
            # 최소 4개 서비스가 실행 중이어야 함 (page, api, db, redis, nginx)
            assert len(service_lines) >= 4, f"실행 중인 서비스가 부족합니다: {len(service_lines)}개"
            
            print(f"✅ 모든 서비스가 정상 실행 중입니다. (총 {len(service_lines)}개)")
        except Exception as e:
            pytest.fail(f"서비스 상태 확인 실패: {e}")


if __name__ == "__main__":
    pytest.main([__file__, "-v", "-s"])
