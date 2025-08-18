from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from dto.user_update_dto import UserUpdateRequest
from models.user import User


class UserService:
    def __init__(self, db: Session):
        self.db = db

    def get_user_by_id(self, user_id: int) -> User:
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        return user

    def change_password(self, user_id: int, old_password: str, new_password: str, current_user: User):
        user = self.get_user_by_id(user_id)

        if current_user.id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only change your own password."
            )

        if not user.verify_password(old_password):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Old password is incorrect"
            )

        user.set_password(new_password)
        self.db.commit()
        return {"message": "Password changed successfully"}

    def update_user(self, user_id: int, user_data: UserUpdateRequest, current_user: User) -> User:
        user = self.get_user_by_id(user_id)

        if current_user.id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only update your own profile."
            )

        for field, value in user_data.dict(exclude_unset=True).items():
            setattr(user, field, value)

        self.db.commit()
        self.db.refresh(user)
        return user

    def delete_user(self, user_id: int, current_user: User):
        user = self.get_user_by_id(user_id)

        if current_user.id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only delete your own account."
            )

        self.db.delete(user)
        self.db.commit()
        return {
            "message": "User deleted successfully",
            "user_id": user_id
        }
