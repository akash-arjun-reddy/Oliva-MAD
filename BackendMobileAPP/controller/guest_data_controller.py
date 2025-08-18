from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session


import logging

from database.session import get_db, get_zenoti_db
from security.jwt import get_current_user
from service.guest_data_service import GuestDataService

logger = logging.getLogger(__name__)

router = APIRouter()

@router.get("/collections/{user_id}")
def get_collections(
        user_id: int,
        current_user = Depends(get_current_user),
        db: Session = Depends(get_db),
        zenoti_db: Session = Depends(get_zenoti_db),
):
    if current_user.id != user_id:
        logger.warning(f"User {current_user.id} unauthorized access attempt for user_id {user_id}")
        raise HTTPException(status_code=403, detail="Not authorized to access this user's collections")

    try:
        service = GuestDataService(db=db, zenoti_db=zenoti_db)
        guest_code = service.get_guest_code_by_user_id(user_id)
        records = service.get_spa_collection_by_guest_code(guest_code)
        return records

    except HTTPException as http_ex:
        logger.warning(f"HTTPException: {http_ex.detail}")
        raise http_ex

    except Exception as ex:
        logger.error(f"Unexpected error: {ex}")
        raise HTTPException(status_code=500, detail="Internal server error")

@router.get("/investigations/{user_id}")
def get_investigations(
        user_id: int,
        current_user = Depends(get_current_user),
        db: Session = Depends(get_db),
        zenoti_db: Session = Depends(get_zenoti_db),
):
    if current_user.id != user_id:
        logger.warning(f"User {current_user.id} unauthorized access attempt for user_id {user_id}")
        raise HTTPException(status_code=403, detail="Not authorized to access this user's investigations")

    try:
        service = GuestDataService(db=db, zenoti_db=zenoti_db)
        guest_code = service.get_guest_code_by_user_id(user_id)
        records = service.get_investigations_by_guest_code(guest_code)
        return records

    except HTTPException as http_ex:
        logger.warning(f"HTTPException: {http_ex.detail}")
        raise http_ex

    except Exception as ex:
        logger.error(f"Unexpected error: {ex}")
        raise HTTPException(status_code=500, detail="Internal server error")

@router.get("/sales/{user_id}")
def get_sales(
        user_id: int,
        current_user = Depends(get_current_user),
        db: Session = Depends(get_db),
        zenoti_db: Session = Depends(get_zenoti_db),
):
    if current_user.id != user_id:
        logger.warning(f"User {current_user.id} unauthorized access attempt for user_id {user_id}")
        raise HTTPException(status_code=403, detail="Not authorized to access this user's sales")

    try:
        service = GuestDataService(db=db, zenoti_db=zenoti_db)
        guest_code = service.get_guest_code_by_user_id(user_id)
        records = service.get_sales_by_guest_code(guest_code)
        return records

    except HTTPException as http_ex:
        logger.warning(f"HTTPException: {http_ex.detail}")
        raise http_ex

    except Exception as ex:
        logger.error(f"Unexpected error: {ex}")
        raise HTTPException(status_code=500, detail="Internal server error")

