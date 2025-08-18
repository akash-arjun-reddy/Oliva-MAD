# dto/user_delete_dto.py

from pydantic import BaseModel

class UserDeleteResponse(BaseModel):
    message: str
    user_id: int

    class Config:
        orm_mode = True
