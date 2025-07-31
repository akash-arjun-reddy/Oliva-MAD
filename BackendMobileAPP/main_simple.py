from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Oliva Clinic API", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"message": "Oliva Clinic Backend API", "status": "success", "docs": "/docs"}

@app.get("/test")
def test_endpoint():
    return {"message": "Backend is working!", "status": "success"}

@app.get("/health")
def health_check():
    return {"status": "healthy", "message": "Backend is running"}

@app.get("/api/status")
def api_status():
    return {
        "service": "Oliva Clinic Backend",
        "status": "running",
        "version": "1.0.0",
        "endpoints": [
            "/",
            "/test",
            "/health",
            "/api/status",
            "/docs"
        ]
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 