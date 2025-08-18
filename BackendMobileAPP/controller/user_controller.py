import os
from dotenv import load_dotenv
from fastapi import APIRouter, Depends, Header, HTTPException
from sqlalchemy.orm import Session
from starlette import status
import logging

from database.session import get_db
from dto.user_admin_pass_dto import ChangePasswordRequest
from dto.user_delete_response_dto import UserDeleteResponse
from dto.user_register_dto import UserResponse
from dto.user_update_dto import UserUpdateRequest
from models.user import User
from security.jwt import get_current_user
from service.user_service import UserService

load_dotenv()
SECRET_KEY = os.getenv("SECRET_KEY")

logger = logging.getLogger(__name__)

router = APIRouter(tags=["User"])

@router.get("/user/{user_id}", response_model=UserResponse)
def get_user_by_id(
    user_id: int,
    db: Session = Depends(get_db),
    x_secret_key: str = Header(..., alias="X-Secret-Key")
):
    if x_secret_key != SECRET_KEY:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Invalid secret key")

    service = UserService(db)
    return service.get_user_by_id(user_id)

@router.post("/change-password/{user_id}")
def change_password(
    user_id: int,
    data: ChangePasswordRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = UserService(db)
    return service.change_password(user_id, data.old_password, data.new_password, current_user)

@router.put("/user/{user_id}", response_model=UserResponse)
def update_user(
    user_id: int,
    user_data: UserUpdateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = UserService(db)
    return service.update_user(user_id, user_data, current_user)

@router.delete("/user/{user_id}", response_model=UserDeleteResponse)
def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = UserService(db)
    return service.delete_user(user_id, current_user)
