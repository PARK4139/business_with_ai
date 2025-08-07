from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(
    title="Hospital Workers Auth Service",
    description="인증 서비스 - 로그인 및 회원가입",
    version="1.0.0"
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Hospital Workers Auth Service", "status": "running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "auth-service"}

# API 엔드포인트
@app.post("/heal_base_hospital_worker/v1/api/ensure/login/")
async def login_api():
    return {"message": "로그인 API", "status": "success"}

# Web 엔드포인트
@app.get("/heal_base_hospital_worker/v1/web/ensure/login/")
async def login_main():
    return {"message": "로그인 메인화면", "status": "success"}

@app.get("/heal_base_hospital_worker/v1/web/ensure/login-guide/")
async def login_guide():
    return {"message": "로그인 가이드", "status": "success"}

@app.get("/heal_base_hospital_worker/v1/web/ensure/login-via-google")
async def login_google():
    return {"message": "구글 로그인", "status": "success"}

@app.get("/heal_base_hospital_worker/v1/web/ensure/signup/")
async def signup_page():
    return {"message": "회원가입 페이지", "status": "success"}

@app.post("/heal_base_hospital_worker/v1/web/ensure/signup-form-submit/")
async def signup_submit():
    return {"message": "회원가입 폼 제출", "status": "success"}

@app.get("/heal_base_hospital_worker/v1/web/ensure/signup-complete/")
async def signup_complete():
    return {"message": "회원가입 완료", "status": "success"}

@app.get("/heal_base_hospital_worker/v1/web/ensure/logined/and/hospital-location-guided/{room}")
async def location_guide(room: str):
    return {
        "message": f"{room}실 위치 가이드",
        "room": room,
        "status": "success",
        "advertisement": "광고 정보"
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
