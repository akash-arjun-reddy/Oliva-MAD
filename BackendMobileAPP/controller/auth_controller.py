from fastapi import APIRouter, Depends, Request, Header
from sqlalchemy.orm import Session
from uuid import uuid4
from typing import Optional, List

from config import settings
from database.session import get_db
from dto.google_auth_dto import OAuthTokenRequest, OAuthUserResponse, OAuthLogoutRequest, \
    OAuthSessionInfo
from dto.user_login_dto import LoginRequest
from dto.user_register_dto import UserCreate
from dto.user_resetpass_dto import PasswordResetRequest, ResetPasswordBody
from service.auth_service import AuthService
from dto.otp_dto import (
    SendOTPRequest, VerifyOTPRequest, SignupWithPhoneRequest, ResetPasswordWithOTPRequest
)

router = APIRouter()

def get_auth_service(db: Session = Depends(get_db)) -> AuthService:
    return AuthService(db)


class AuthController:
    def __init__(self, service: AuthService):
        self.service = service

    async def register_user(self, user: UserCreate):
        return self.service.register_user(user)

    async def login_user(self, request_id: str, ip: str, data: LoginRequest):
        return self.service.login_user(request_id, data, ip)

    async def request_password_reset(self, data: PasswordResetRequest):
        return self.service.request_password_reset(data)

    async def reset_password(self, data: ResetPasswordBody):
        return self.service.reset_password(data)

    async def google_auth(self, request_id: str, ip: str, data: OAuthTokenRequest):
        return await self.service.authenticate_google(request_id, data, ip)

    async def oauth_auth(self, request_id: str, ip: str, data: OAuthTokenRequest) -> OAuthUserResponse:
        return await self.service.authenticate_oauth(request_id, data, ip)

    async def oauth_logout(self, data: OAuthLogoutRequest):
        return await self.service.logout_oauth(data)

    async def get_oauth_sessions(self, user_id: str) -> List[OAuthSessionInfo]:
        return await self.service.get_oauth_sessions(user_id)


def get_auth_controller(service: AuthService = Depends(get_auth_service)) -> AuthController:
    return AuthController(service)


def get_client_ip(request: Request) -> str:
    x_forwarded_for = request.headers.get("x-forwarded-for")
    if x_forwarded_for:
        # sometimes x-forwarded-for can have multiple IPs, take the first one
        ip = x_forwarded_for.split(",")[0].strip()
    else:
        ip = request.client.host
    return ip


def get_request_id(x_request_id: Optional[str] = Header(None)) -> str:
    return x_request_id or str(uuid4())


@router.post("/register")
async def register_user(
        user: UserCreate,
        controller: AuthController = Depends(get_auth_controller),
):
    return await controller.register_user(user)


@router.post("/login")
async def login_user(
        request: Request,
        data: LoginRequest,
        request_id: str = Depends(get_request_id),
        controller: AuthController = Depends(get_auth_controller),
):
    ip = get_client_ip(request)
    return await controller.login_user(request_id, ip, data)


@router.post("/request-password-reset")
async def request_password_reset(
        data: PasswordResetRequest,
        controller: AuthController = Depends(get_auth_controller),
):
    return await controller.request_password_reset(data)


@router.post("/reset-password")
async def reset_password(
        data: ResetPasswordBody,
        controller: AuthController = Depends(get_auth_controller),
):
    return await controller.reset_password(data)


@router.post("/auth/oauth")
async def oauth_auth(
        request: Request,
        data: OAuthTokenRequest,
        request_id: str = Depends(get_request_id),
        controller: AuthController = Depends(get_auth_controller),
):
    ip = get_client_ip(request)
    return await controller.oauth_auth(request_id, ip, data)


@router.post("/auth/oauth/logout")
async def oauth_logout(
        data: OAuthLogoutRequest,
        controller: AuthController = Depends(get_auth_controller),
):
    return await controller.oauth_logout(data)


@router.get("/auth/oauth/sessions/{user_id}")
async def get_oauth_sessions(
        user_id: str,
        controller: AuthController = Depends(get_auth_controller),
):
    return await controller.get_oauth_sessions(user_id)


@router.get("/auth/oauth/test-config")
async def test_oauth_config(
        controller: AuthController = Depends(get_auth_controller),
):
    """Test endpoint to verify OAuth configuration."""
    return {
        "status": "OAuth configuration is ready",
        "google_client_id": settings.GOOGLE_CLIENT_ID[:10] + "..." if settings.GOOGLE_CLIENT_ID else "Not configured",
        "supported_providers": ["google"],
        "endpoints": {
            "oauth_auth": "/auth/oauth",
            "oauth_logout": "/auth/oauth/logout",
            "oauth_sessions": "/auth/oauth/sessions/{user_id}"
        }
    }


# --- Add phone/OTP endpoints (function-based) ---
@router.post("/auth/send-otp")
def send_otp(data: SendOTPRequest, service: AuthService = Depends(get_auth_service)):
    return service.send_otp(data)

@router.post("/auth/verify-otp")
def verify_otp(data: VerifyOTPRequest, service: AuthService = Depends(get_auth_service)):
    return service.verify_otp(data)

@router.post("/auth/signup-phone")
def signup_with_phone(data: SignupWithPhoneRequest, service: AuthService = Depends(get_auth_service)):
    return service.signup_with_phone(data)

@router.post("/auth/login-phone")
def login_with_phone(data: SendOTPRequest, service: AuthService = Depends(get_auth_service)):
    return service.login_with_phone(data)

@router.post("/auth/verify-login-otp")
def verify_login_otp(data: VerifyOTPRequest, service: AuthService = Depends(get_auth_service)):
    return service.verify_login_otp(data)

@router.post("/auth/forgot-password-phone")
def forgot_password_phone(data: SendOTPRequest, service: AuthService = Depends(get_auth_service)):
    return service.forgot_password_phone(data)

@router.post("/auth/reset-password-phone")
def reset_password_phone(data: ResetPasswordWithOTPRequest, service: AuthService = Depends(get_auth_service)):
    return service.reset_password_phone(data) 