from pydantic import BaseModel, validator

class LoginRequest(BaseModel):
    login: str
    password: str

    @validator("login")
    def login_must_be_email(cls, v):
        if not v or v.strip() == "":
            raise ValueError("Login field must not be empty")
        return v.strip()


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class ResetPasswordRequest(BaseModel):
    username: str
    new_password: str


