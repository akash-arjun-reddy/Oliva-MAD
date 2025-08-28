from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session
from database.session import get_db
from service.session_service import SessionService
from typing import List
from datetime import datetime

router = APIRouter(prefix="/sessions", tags=["sessions"])

@router.get("/my-sessions")
async def get_my_sessions(request: Request, db: Session = Depends(get_db)):
    """Get current user's active sessions."""
    session_service = SessionService(db)
    
    # Get token from Authorization header
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")
    
    token = auth_header.split(" ")[1]
    user = session_service.get_user_from_token(token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    sessions = session_service.get_user_sessions(user.id)
    return {
        "user_id": user.id,
        "sessions": [
            {
                "id": session.id,
                "device_info": session.device_info,
                "ip_address": session.ip_address,
                "is_active": session.is_active,
                "created_at": session.created_at,
                "last_activity": session.last_activity,
                "expires_at": session.expires_at
            }
            for session in sessions
        ]
    }

@router.get("/my-session-logs")
async def get_my_session_logs(request: Request, db: Session = Depends(get_db)):
    """Get current user's session logs."""
    session_service = SessionService(db)
    
    # Get token from Authorization header
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")
    
    token = auth_header.split(" ")[1]
    user = session_service.get_user_from_token(token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    logs = session_service.get_user_session_logs(user.id)
    return {
        "user_id": user.id,
        "logs": [
            {
                "id": log.id,
                "action": log.action,
                "ip_address": log.ip_address,
                "success": log.success,
                "error_message": log.error_message,
                "created_at": log.created_at
            }
            for log in logs
        ]
    }

@router.post("/logout")
async def logout(request: Request, db: Session = Depends(get_db)):
    """Logout current session."""
    session_service = SessionService(db)
    
    # Get token from Authorization header
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")
    
    token = auth_header.split(" ")[1]
    user = session_service.get_user_from_token(token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # Deactivate current session
    success = session_service.deactivate_session(
        token, 
        ip_address=request.client.host,
        user_agent=request.headers.get("User-Agent")
    )
    
    if success:
        return {"message": "Successfully logged out"}
    else:
        raise HTTPException(status_code=400, detail="Session not found or already inactive")

@router.post("/logout-all")
async def logout_all_devices(request: Request, db: Session = Depends(get_db)):
    """Logout from all devices."""
    session_service = SessionService(db)
    
    # Get token from Authorization header
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")
    
    token = auth_header.split(" ")[1]
    user = session_service.get_user_from_token(token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # Deactivate all sessions for user
    count = session_service.deactivate_all_user_sessions(
        user.id,
        ip_address=request.client.host,
        user_agent=request.headers.get("User-Agent")
    )
    
    return {"message": f"Successfully logged out from {count} devices"}

@router.post("/refresh")
async def refresh_session(request: Request, db: Session = Depends(get_db)):
    """Refresh current session activity."""
    session_service = SessionService(db)
    
    # Get token from Authorization header
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")
    
    token = auth_header.split(" ")[1]
    user = session_service.get_user_from_token(token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # Update session activity
    success = session_service.update_session_activity(token)
    if success:
        return {"message": "Session refreshed successfully"}
    else:
        raise HTTPException(status_code=400, detail="Session not found or expired")

@router.get("/status")
async def get_session_status(request: Request, db: Session = Depends(get_db)):
    """Get current session status."""
    session_service = SessionService(db)
    
    # Get token from Authorization header
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")
    
    token = auth_header.split(" ")[1]
    user = session_service.get_user_from_token(token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    session = session_service.get_active_session(token)
    if session:
        return {
            "is_active": True,
            "user_id": user.id,
            "username": user.username,
            "email": user.email,
            "session_created": session.created_at,
            "last_activity": session.last_activity,
            "expires_at": session.expires_at,
            "device_info": session.device_info,
            "ip_address": session.ip_address
        }
    else:
        return {
            "is_active": False,
            "message": "Session expired or inactive"
        }
