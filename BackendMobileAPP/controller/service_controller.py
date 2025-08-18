from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text

import traceback

from database.session import get_zenoti_db

router = APIRouter(
    prefix="/api",
    tags=["services"]
)

@router.get("/services")
def get_all_services(db: Session = Depends(get_zenoti_db)):
    try:
        query = text("SELECT * FROM test.service_master ORDER BY id ASC;")
        result = db.execute(query).fetchall()

        # Convert the list of Row objects to a list of dictionaries
        services = [row._asdict() for row in result]

        return services
    except Exception as e:
        print("--- DETAILED ERROR TRACEBACK ---")
        traceback.print_exc()
        print("------------------------------------")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}") 