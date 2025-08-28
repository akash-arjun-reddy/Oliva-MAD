from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from models.session import UserSession, SessionLog
from models.user import User
from typing import Optional, List
import jwt
from config.settings import settings

class SessionService:
    def __init__(self, db: Session):
        self.db = db
    
    def create_session(self, user_id: int, token: str, ip_address: str = None, 
                      user_agent: str = None, device_info: str = None) -> UserSession:
        """Create a new user session."""
        expires_at = datetime.utcnow() + timedelta(hours=settings.ACCESS_TOKEN_EXPIRE_MINUTES / 60)
        
        session = UserSession(
            user_id=user_id,
            session_token=token,
            ip_address=ip_address,
            user_agent=user_agent,
            device_info=device_info,
            expires_at=expires_at
        )
        
        self.db.add(session)
        self.db.commit()
        self.db.refresh(session)
        
        # Log session creation
        self.log_session_action(user_id, "login", token, ip_address, user_agent, True)
        
        return session
    
    def get_active_session(self, token: str) -> Optional[UserSession]:
        """Get active session by token."""
        return self.db.query(UserSession).filter(
            UserSession.session_token == token,
            UserSession.is_active == True,
            UserSession.expires_at > datetime.utcnow()
        ).first()
    
    def update_session_activity(self, token: str) -> bool:
        """Update last activity time for session."""
        session = self.get_active_session(token)
        if session:
            session.last_activity = datetime.utcnow()
            self.db.commit()
            return True
        return False
    
    def deactivate_session(self, token: str, ip_address: str = None, 
                          user_agent: str = None) -> bool:
        """Deactivate a session (logout)."""
        session = self.get_active_session(token)
        if session:
            session.is_active = False
            self.db.commit()
            
            # Log logout
            self.log_session_action(session.user_id, "logout", token, ip_address, user_agent, True)
            return True
        return False
    
    def deactivate_all_user_sessions(self, user_id: int, ip_address: str = None, 
                                    user_agent: str = None) -> int:
        """Deactivate all sessions for a user."""
        sessions = self.db.query(UserSession).filter(
            UserSession.user_id == user_id,
            UserSession.is_active == True
        ).all()
        
        for session in sessions:
            session.is_active = False
            self.log_session_action(user_id, "logout", session.session_token, 
                                  ip_address, user_agent, True)
        
        self.db.commit()
        return len(sessions)
    
    def cleanup_expired_sessions(self) -> int:
        """Clean up expired sessions."""
        expired_sessions = self.db.query(UserSession).filter(
            UserSession.expires_at <= datetime.utcnow(),
            UserSession.is_active == True
        ).all()
        
        for session in expired_sessions:
            session.is_active = False
            self.log_session_action(session.user_id, "session_expired", 
                                  session.session_token, None, None, True)
        
        self.db.commit()
        return len(expired_sessions)
    
    def get_user_sessions(self, user_id: int) -> List[UserSession]:
        """Get all sessions for a user."""
        return self.db.query(UserSession).filter(
            UserSession.user_id == user_id
        ).order_by(UserSession.created_at.desc()).all()
    
    def get_user_session_logs(self, user_id: int, limit: int = 50) -> List[SessionLog]:
        """Get session logs for a user."""
        return self.db.query(SessionLog).filter(
            SessionLog.user_id == user_id
        ).order_by(SessionLog.created_at.desc()).limit(limit).all()
    
    def log_session_action(self, user_id: int, action: str, token: str = None, 
                          ip_address: str = None, user_agent: str = None, 
                          success: bool = True, error_message: str = None):
        """Log session actions."""
        log = SessionLog(
            user_id=user_id,
            action=action,
            session_token=token,
            ip_address=ip_address,
            user_agent=user_agent,
            success=success,
            error_message=error_message
        )
        
        self.db.add(log)
        self.db.commit()
    
    def validate_token(self, token: str) -> Optional[dict]:
        """Validate JWT token and return payload."""
        try:
            payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
            return payload
        except jwt.ExpiredSignatureError:
            return None
        except jwt.InvalidTokenError:
            return None
    
    def get_user_from_token(self, token: str) -> Optional[User]:
        """Get user from JWT token."""
        payload = self.validate_token(token)
        if payload:
            username = payload.get("sub")
            if username:
                return self.db.query(User).filter(User.username == username).first()
        return None
