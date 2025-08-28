from fastapi import FastAPI, Request, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from typing import Dict, Any, Optional
import time
import json

from database.session import get_db
from service.security_service import SecurityService
from middleware.rate_limit import GENERAL_RATE_LIMIT
from security.jwt import get_current_user


class APIGateway:
    def __init__(self):
        self.app = FastAPI(title="Oliva Clinic API Gateway", version="2.0.0")
        self._setup_middleware()
        self._setup_routes()
    
    def _setup_middleware(self):
        """Setup security and monitoring middleware."""
        # CORS
        self.app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],  # Configure for production
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )
        
        # Trusted hosts
        self.app.add_middleware(
            TrustedHostMiddleware,
            allowed_hosts=["*"]  # Configure for production
        )
        
        # Request logging middleware
        self.app.middleware("http")(self._log_request)
        
        # Rate limiting middleware
        self.app.middleware("http")(self._rate_limit_middleware)
    
    def _setup_routes(self):
        """Setup gateway routes."""
        @self.app.middleware("http")
        async def add_process_time_header(request: Request, call_next):
            start_time = time.time()
            response = await call_next(request)
            process_time = time.time() - start_time
            response.headers["X-Process-Time"] = str(process_time)
            return response
        
        @self.app.exception_handler(HTTPException)
        async def http_exception_handler(request: Request, exc: HTTPException):
            return JSONResponse(
                status_code=exc.status_code,
                content={
                    "error": exc.detail,
                    "timestamp": time.time(),
                    "path": request.url.path
                }
            )
        
        @self.app.exception_handler(Exception)
        async def general_exception_handler(request: Request, exc: Exception):
            return JSONResponse(
                status_code=500,
                content={
                    "error": "Internal server error",
                    "timestamp": time.time(),
                    "path": request.url.path
                }
            )
    
    async def _log_request(self, request: Request, call_next):
        """Log all requests for monitoring."""
        start_time = time.time()
        
        # Get request details
        method = request.method
        url = str(request.url)
        client_ip = request.client.host
        user_agent = request.headers.get("user-agent", "")
        
        # Process request
        response = await call_next(request)
        
        # Calculate processing time
        process_time = time.time() - start_time
        
        # Log request (you can integrate with your logging system)
        log_data = {
            "timestamp": time.time(),
            "method": method,
            "url": url,
            "client_ip": client_ip,
            "user_agent": user_agent,
            "status_code": response.status_code,
            "process_time": process_time
        }
        
        # You can send this to your logging service
        print(f"API Gateway Log: {json.dumps(log_data)}")
        
        return response
    
    async def _rate_limit_middleware(self, request: Request, call_next):
        """Apply rate limiting to all requests."""
        # Skip rate limiting for health checks
        if request.url.path in ["/health", "/docs", "/openapi.json"]:
            return await call_next(request)
        
        # Apply general rate limiting
        db = next(get_db())
        security_service = SecurityService(db)
        
        # Get identifier
        client_ip = request.client.host
        x_forwarded_for = request.headers.get("x-forwarded-for")
        if x_forwarded_for:
            client_ip = x_forwarded_for.split(",")[0].strip()
        
        # Check rate limit
        if not security_service.check_rate_limit(client_ip, "api_request", 100, 15):
            return JSONResponse(
                status_code=429,
                content={
                    "error": "Rate limit exceeded",
                    "message": "Too many requests. Please try again later.",
                    "retry_after": 900  # 15 minutes
                }
            )
        
        return await call_next(request)
    
    def add_route(self, path: str, router, prefix: str = "", tags: list = None):
        """Add a route to the gateway."""
        self.app.include_router(router, prefix=prefix, tags=tags or [])
    
    def get_app(self) -> FastAPI:
        """Get the FastAPI app instance."""
        return self.app


# Create global gateway instance
gateway = APIGateway()


def get_gateway() -> APIGateway:
    """Get the API gateway instance."""
    return gateway


# Health check endpoint
@gateway.app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "service": "API Gateway",
        "timestamp": time.time(),
        "version": "2.0.0"
    }


# Gateway info endpoint
@gateway.app.get("/gateway/info")
async def gateway_info():
    """Get gateway information."""
    return {
        "service": "Oliva Clinic API Gateway",
        "version": "2.0.0",
        "features": [
            "Rate Limiting",
            "Request Logging",
            "CORS Support",
            "Security Middleware",
            "Error Handling"
        ],
        "timestamp": time.time()
    }
