from sqlalchemy.orm import Session
from sqlalchemy import and_
from typing import List, Optional
from models.meeting import Meeting
from database.connection_simple import get_db

class MeetingRepository:
    def __init__(self, db: Session):
        self.db = db
    
    async def create_meeting(self, meeting_data: dict) -> Meeting:
        """Create a new meeting"""
        meeting = Meeting(**meeting_data)
        self.db.add(meeting)
        self.db.commit()
        self.db.refresh(meeting)
        return meeting
    
    async def get_meeting_by_id(self, meeting_id: str) -> Optional[Meeting]:
        """Get meeting by meeting_id"""
        return self.db.query(Meeting).filter(Meeting.meeting_id == meeting_id).first()
    
    async def get_meetings_by_customer(self, customer_name: str) -> List[Meeting]:
        """Get all meetings for a customer"""
        return self.db.query(Meeting).filter(Meeting.customer_name == customer_name).all()
    
    async def get_meetings_by_doctor(self, doctor_name: str) -> List[Meeting]:
        """Get all meetings for a doctor"""
        return self.db.query(Meeting).filter(Meeting.doctor_name == doctor_name).all()
    
    async def get_all_meetings(self, skip: int = 0, limit: int = 100) -> List[Meeting]:
        """Get all meetings with pagination"""
        return self.db.query(Meeting).offset(skip).limit(limit).all()
    
    async def update_meeting_status(self, meeting_id: str, status: str) -> Optional[Meeting]:
        """Update meeting status"""
        meeting = await self.get_meeting_by_id(meeting_id)
        if meeting:
            meeting.status = status
            self.db.commit()
            self.db.refresh(meeting)
        return meeting
    
    async def delete_meeting(self, meeting_id: str) -> bool:
        """Delete a meeting"""
        meeting = await self.get_meeting_by_id(meeting_id)
        if meeting:
            self.db.delete(meeting)
            self.db.commit()
            return True
        return False
    
    async def get_active_meetings(self) -> List[Meeting]:
        """Get all active meetings"""
        return self.db.query(Meeting).filter(Meeting.status == "active").all()

def get_meeting_repository():
    """Dependency to get meeting repository"""
    db = next(get_db())
    return MeetingRepository(db)
