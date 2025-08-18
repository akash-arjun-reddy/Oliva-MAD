from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config.settings import settings
from app.controllers.doctor_controller import router as doctor_router
from app.controllers.appointment_controller import router as appointment_router
from app.controllers.meeting_controller import router as meeting_router
from app.database.connection import engine, Base, create_schema_if_not_exists
from app.database.init_db import init_database

# Initialize database with tables and sample data
try:
    init_database()
    print("✅ Database initialized successfully")
except Exception as e:
    print(f"⚠️ Database initialization warning: {e}")

# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    debug=settings.DEBUG
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(doctor_router)
app.include_router(appointment_router)
app.include_router(meeting_router)

# Root endpoint
@app.get("/")
async def root():
    return {"message": "Oliva Virtual Clinic API", "status": "running"}

# Health check
@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    print("🚀 Starting Oliva Virtual Clinic Backend...")
    uvicorn.run(
        app, 
        host="127.0.0.1", 
        port=8002,
        reload=False
    ) 