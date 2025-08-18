from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from controller import booking_controller, guest_data_controller
from controller import appointment_controller
from controller import auth_controller
from controller import user_controller
from controller import service_controller
from controller.loyalty_controller import router as loyalty_router
from database.connection import create_tables
from controller.guest_data_controller import router as collections_router
from controller.consultation_controller import router as consultation_router

from fastapi import APIRouter

from controller import payment_controller
from shopify_controller import router as shopify_router

import models
# Import order models to ensure tables are created
from models.order_models import Order, OrderItem, PaymentTransaction, OrderEvent, Customer, Product, InventoryLog

app = FastAPI(title="Oliva Clinic API", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def startup_db_client():
    try:
        create_tables()
        print("Database tables created successfully")
    except Exception as e:
        print(f"Error creating tables: {e}")

app.include_router(auth_controller.router)
app.include_router(user_controller.router)
app.include_router(appointment_controller.router)
app.include_router(service_controller.router)
app.include_router(loyalty_router)
app.include_router(collections_router)
app.include_router(booking_controller.router)
app.include_router(guest_data_controller.router)
app.include_router(payment_controller.router)
app.include_router(shopify_router)
app.include_router(consultation_router)

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
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
