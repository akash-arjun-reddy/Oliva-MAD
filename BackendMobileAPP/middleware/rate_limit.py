from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
from typing import Dict, Any, Optional
import time
from database.session import get_db
from service.security_service import SecurityService


class RateLimitMiddleware:
    def __init__(self, max_attempts: int = 5, window_minutes: int = 15):
        self.max_attempts = max_attempts
        self.window_minutes = window_minutes
    
    async def __call__(self, request: Request, call_next):
        # Get identifier (IP address or user ID if authenticated)
        identifier = self._get_identifier(request)
        action = self._get_action(request)
        
        # Check rate limit
        db = next(get_db())
        security_service = SecurityService(db)
        
        if not security_service.check_rate_limit(identifier, action, self.max_attempts, self.window_minutes):
            return JSONResponse(
                status_code=429,
                content={
                    "error": "Rate limit exceeded",
                    "message": f"Too many requests. Please try again in {self.window_minutes} minutes.",
                    "retry_after": self.window_minutes * 60
                }
            )
        
        # Log the request
        security_service.log_audit_event(
            user_id=self._get_user_id(request),
            action=action,
            resource=request.url.path,
            ip_address=request.client.host,
            user_agent=request.headers.get("user-agent"),
            success=True
        )
        
        response = await call_next(request)
        return response
    
    def _get_identifier(self, request: Request) -> str:
        """Get identifier for rate limiting (IP or user ID)."""
        # Try to get user ID from token if available
        user_id = self._get_user_id(request)
        if user_id:
            return f"user:{user_id}"
        
        # Fall back to IP address
        x_forwarded_for = request.headers.get("x-forwarded-for")
        if x_forwarded_for:
            return x_forwarded_for.split(",")[0].strip()
        return request.client.host
    
    def _get_user_id(self, request: Request) -> Optional[str]:
        """Extract user ID from request if available."""
        # This would need to be implemented based on your JWT verification
        # For now, return None
        return None
    
    def _get_action(self, request: Request) -> str:
        """Get action name for rate limiting."""
        method = request.method.lower()
        path = request.url.path
        
        # Map common actions
        if path.startswith("/auth/login"):
            return "login"
        elif path.startswith("/auth/register"):
            return "register"
        elif path.startswith("/auth/request-password-reset"):
            return "password_reset"
        elif path.startswith("/auth/google"):
            return "oauth_login"
        else:
            return f"{method}:{path}"


def create_rate_limit_middleware(max_attempts: int = 5, window_minutes: int = 15):
    """Factory function to create rate limit middleware."""
    return RateLimitMiddleware(max_attempts, window_minutes)


# Predefined rate limit configurations
LOGIN_RATE_LIMIT = create_rate_limit_middleware(max_attempts=5, window_minutes=15)
REGISTER_RATE_LIMIT = create_rate_limit_middleware(max_attempts=3, window_minutes=60)
PASSWORD_RESET_RATE_LIMIT = create_rate_limit_middleware(max_attempts=3, window_minutes=60)
GENERAL_RATE_LIMIT = create_rate_limit_middleware(max_attempts=100, window_minutes=15)
