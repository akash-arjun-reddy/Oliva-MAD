from fastapi import FastAPI

from controller import booking_controller, guest_data_controller
from controller import appointment_controller
from controller import auth_controller
from controller import user_controller
from controller import service_controller
from controller.loyalty_controller import router as loyalty_router
from database.connection import create_tables
from controller.guest_data_controller import router as collections_router

from fastapi import APIRouter

from controller import payment_controller

import models

app = FastAPI()

@app.on_event("startup")
def startup_db_client():
    create_tables()

app.include_router(auth_controller.router)
app.include_router(user_controller.router)
app.include_router(appointment_controller.router)
app.include_router(service_controller.router)
app.include_router(loyalty_router)
app.include_router(collections_router)
app.include_router(booking_controller.router)
app.include_router(guest_data_controller.router)
app.include_router(payment_controller.router)

@app.get("/test")
def test_endpoint():
    return {"message": "Backend is working!", "status": "success"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
