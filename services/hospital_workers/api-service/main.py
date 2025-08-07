from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(
    title="Hospital Workers API Service",
    description="비즈니스 로직 서비스 - API 엔드포인트",
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
    return {"message": "Hospital Workers API Service", "status": "running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "api-service"}

# API 엔드포인트
@app.post("/heal_base_hospital_worker/v1/api/ensure/login/")
async def login_api():
    return {"message": "로그인 API 처리", "status": "success"}

@app.get("/heal_base_hospital_worker/v1/api/ensure/user/profile/")
async def user_profile():
    return {"message": "사용자 프로필 API", "status": "success"}

@app.get("/heal_base_hospital_worker/v1/api/ensure/hospital/locations/")
async def hospital_locations():
    return {"message": "병원 위치 정보 API", "status": "success"}

@app.get("/heal_base_hospital_worker/v1/api/ensure/hospital/location/{room}")
async def hospital_location(room: str):
    return {
        "message": f"{room}실 위치 정보",
        "room": room,
        "status": "success",
        "coordinates": {"lat": 37.5665, "lng": 126.9780}
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
