#!/usr/bin/env python3
"""
로그인 루틴 테스트 실행 + 스크린샷 뷰어 자동 생성/오픈 스크립트
- pytest로 로그인 관련 테스트만 실행
- HTML 리포트 생성: logs/login_report.html
- 스크린샷 뷰어 생성: logs/login_screenshots.html
- 실행 후 뷰어 자동 오픈 (Windows/WSL/Linux 지원 시도)
"""
from __future__ import annotations

import os
import sys
import subprocess
from pathlib import Path
import platform
from typing import List

SERVICE_ROOT = Path(__file__).resolve().parent.parent
TEST_FILE = SERVICE_ROOT / "tests" / "test_login_routine_via_selenium_at_windows.py"
RESULTS_DIR = SERVICE_ROOT / "tests" / "results"
LOGS_DIR = SERVICE_ROOT / "logs"
HTML_REPORT = LOGS_DIR / "login_report.html"
VIEWER_HTML = LOGS_DIR / "login_screenshots.html"

TEST_EXPR = (
    "test_page_load_and_title or "
    "test_login_form_structure or "
    "test_form_interaction or "
    "test_browser_functionality"
)

VIEW_TITLES = {
    "01_mock_page_load_success.png": "모의 페이지 로드 성공",
    "01_prefix_page_load_success.png": "프리픽스 페이지 로드 성공",
    "01_real_page_load_success.png": "실제 페이지 로드 성공",
    "02_page_load_failed.png": "페이지 로드 실패",
    "02_real_page_load_failed.png": "실제 페이지 로드 실패",
    "03_login_form_structure_failed.png": "로그인 폼 구조 실패",
    "04_form_interaction_success.png": "폼 상호작용 성공",
    "04_prefix_login_test_result.png": "프리픽스 로그인 테스트 결과",
    "05_browser_size_1024x768.png": "브라우저 해상도 1024x768",
    "05_browser_size_1366x768.png": "브라우저 해상도 1366x768",
    "05_browser_size_1920x1080.png": "브라우저 해상도 1920x1080",
    "05_login_test_failed.png": "로그인 테스트 실패",
    "06_browser_refresh_test.png": "브라우저 새로고침 테스트",
    "07_invalid_login_test_failed.png": "잘못된 로그인 시도 실패",
    "07_selenium_capabilities_failed.png": "Selenium 기능 테스트 실패",
    "08_comprehensive_test_result.png": "종합 테스트 결과",
    "08_form_validation_test_result.png": "폼 검증 테스트 결과",
}


def ensure_dirs() -> None:
    LOGS_DIR.mkdir(parents=True, exist_ok=True)
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)


def ensure_pytest_html_installed() -> None:
    try:
        import pytest_html  # type: ignore
        return
    except Exception:
        pass
    # 미설치 시 현재 파이썬에 설치
    subprocess.run([sys.executable, "-m", "pip", "install", "-q", "pytest-html"], check=False)


def run_pytest() -> int:
    cmd = [
        sys.executable, "-m", "pytest",
        str(TEST_FILE),
        "-k", TEST_EXPR,
        "-v", "-s",
        "--html", str(HTML_REPORT),
        "--self-contained-html",
    ]
    print("[RUN] ", " ".join(cmd))
    proc = subprocess.run(cmd, cwd=str(SERVICE_ROOT))
    return proc.returncode


def list_screenshots() -> List[Path]:
    if not RESULTS_DIR.exists():
        return []
    files = [p for p in RESULTS_DIR.iterdir() if p.is_file() and p.suffix.lower() == ".png"]
    # 파일명 기준 정렬(숫자 프리픽스 순)
    files.sort(key=lambda p: p.name)
    return files


def render_viewer(files: List[Path]) -> None:
    items_html = []
    for f in files:
        rel_src = os.path.relpath(f, LOGS_DIR).replace("\\", "/")
        title = VIEW_TITLES.get(f.name, f.name)
        items_html.append(
            f'<div class="item"><h2>{f.name}</h2><p>{title}</p><img src="{rel_src}" alt="{f.name}"></div>'
        )

    html = f"""<!DOCTYPE html>
<html lang=\"ko\">
<head>
  <meta charset=\"utf-8\" />
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
  <title>로그인 루틴 스크린샷 뷰어</title>
  <style>
    body {{ font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; margin: 24px; background: #f8fafc; color: #0f172a; }}
    h1 {{ font-size: 24px; margin-bottom: 16px; }}
    .item {{ background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 16px; margin: 16px 0; box-shadow: 0 1px 2px rgba(0,0,0,0.04); }}
    .item h2 {{ margin: 0 0 8px; font-size: 18px; }}
    .item p {{ margin: 0 0 12px; color: #475569; }}
    .item img {{ max-width: 100%; height: auto; border-radius: 8px; border: 1px solid #e2e8f0; }}
    .path {{ font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 12px; color: #64748b; }}
  </style>
</head>
<body>
  <h1>로그인 루틴 스크린샷</h1>
  <p class=\"path\">폴더: services/hospital_workers/tests/results</p>
  {''.join(items_html)}
</body>
</html>
"""
    VIEWER_HTML.write_text(html, encoding="utf-8")


def is_wsl() -> bool:
    try:
        if "WSL_DISTRO_NAME" in os.environ:
            return True
        return "microsoft" in platform.release().lower()
    except Exception:
        return False


def try_open(path: Path) -> bool:
    """뷰어 파일을 가능한 방식으로 연다. 성공 시 True 반환."""
    try:
        # Windows 네이티브
        if os.name == "nt":
            try:
                os.startfile(str(path))  # type: ignore[attr-defined]
                print(f"[OPEN] Windows os.startfile OK -> {path}")
                return True
            except Exception as e:
                print(f"[OPEN] Windows os.startfile 실패: {e}")

        # WSL 우선순위: explorer.exe -> wslview -> xdg-open
        if is_wsl():
            try:
                win_path = subprocess.check_output(["wslpath", "-w", str(path)], stderr=subprocess.STDOUT).decode().strip()
                res = subprocess.run(["explorer.exe", win_path])
                if res.returncode == 0:
                    print(f"[OPEN] WSL explorer.exe OK -> {win_path}")
                    return True
                else:
                    print(f"[OPEN] WSL explorer.exe 실패 (code={res.returncode})")
            except Exception as e:
                print(f"[OPEN] WSL explorer.exe 시도 실패: {e}")

        # 공통 리눅스 시도 1: wslview
        try:
            res = subprocess.run(["wslview", str(path)])
            if res.returncode == 0:
                print(f"[OPEN] wslview OK -> {path}")
                return True
            else:
                print(f"[OPEN] wslview 실패 (code={res.returncode})")
        except FileNotFoundError:
            print("[OPEN] wslview 미설치")
        except Exception as e:
            print(f"[OPEN] wslview 시도 실패: {e}")

        # 공통 리눅스 시도 2: xdg-open
        try:
            res = subprocess.run(["xdg-open", str(path)])
            if res.returncode == 0:
                print(f"[OPEN] xdg-open OK -> {path}")
                return True
            else:
                print(f"[OPEN] xdg-open 실패 (code={res.returncode})")
        except FileNotFoundError:
            print("[OPEN] xdg-open 미설치")
        except Exception as e:
            print(f"[OPEN] xdg-open 시도 실패: {e}")

        # 마지막 안내
        print("[OPEN] 자동 열기에 실패했습니다. 아래 경로를 브라우저로 열어주세요:")
        print(f"  - WSL 경로: {path}")
        try:
            win_path = subprocess.check_output(["wslpath", "-w", str(path)], stderr=subprocess.STDOUT).decode().strip()
            print(f"  - Windows 경로: {win_path}")
        except Exception:
            pass
        return False
    except Exception as e:
        print(f"[OPEN] 예외 발생: {e}")
        return False


def main() -> int:
    ensure_dirs()
    ensure_pytest_html_installed()
    code = run_pytest()
    files = list_screenshots()
    render_viewer(files)
    print(f"[OK] HTML Report: {HTML_REPORT}")
    print(f"[OK] Screenshots Viewer: {VIEWER_HTML}")
    opened = try_open(VIEWER_HTML)
    if not opened:
        print("[HINT] 수동으로 파일을 열어 리포트/스크린샷을 확인하세요.")
    return code


if __name__ == "__main__":
    raise SystemExit(main())
