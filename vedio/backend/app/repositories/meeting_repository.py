from abc import ABC, abstractmethod
from typing import List, Optional
from datetime import datetime
from app.models.meeting import MeetingResponse

class MeetingRepository(ABC):
    """Abstract repository interface for meeting operations"""
    
    @abstractmethod
    async def create_meeting(self, meeting: MeetingResponse) -> MeetingResponse:
        """Create a new meeting record"""
        pass
    
    @abstractmethod
    async def get_meeting_by_id(self, meeting_id: str) -> Optional[MeetingResponse]:
        """Get meeting by ID"""
        pass
    
    @abstractmethod
    async def get_meetings_by_customer(self, customer_name: str) -> List[MeetingResponse]:
        """Get all meetings for a customer"""
        pass
    
    @abstractmethod
    async def get_meetings_by_doctor(self, doctor_name: str) -> List[MeetingResponse]:
        """Get all meetings for a doctor"""
        pass
    
    @abstractmethod
    async def get_meetings_by_date_range(self, start_date: datetime, end_date: datetime) -> List[MeetingResponse]:
        """Get meetings within a date range"""
        pass
    
    @abstractmethod
    async def delete_meeting(self, meeting_id: str) -> bool:
        """Delete a meeting by ID"""
        pass

class InMemoryMeetingRepository(MeetingRepository):
    """In-memory implementation of meeting repository (for development/testing)"""
    
    def __init__(self):
        self.meetings: List[MeetingResponse] = []
    
    async def create_meeting(self, meeting: MeetingResponse) -> MeetingResponse:
        """Create a new meeting record in memory"""
        self.meetings.append(meeting)
        return meeting
    
    async def get_meeting_by_id(self, meeting_id: str) -> Optional[MeetingResponse]:
        """Get meeting by ID from memory"""
        for meeting in self.meetings:
            if meeting.meeting_id == meeting_id:
                return meeting
        return None
    
    async def get_meetings_by_customer(self, customer_name: str) -> List[MeetingResponse]:
        """Get all meetings for a customer from memory"""
        return [meeting for meeting in self.meetings if meeting.customer_name == customer_name]
    
    async def get_meetings_by_doctor(self, doctor_name: str) -> List[MeetingResponse]:
        """Get all meetings for a doctor from memory"""
        return [meeting for meeting in self.meetings if meeting.doctor_name == doctor_name]
    
    async def get_meetings_by_date_range(self, start_date: datetime, end_date: datetime) -> List[MeetingResponse]:
        """Get meetings within a date range from memory"""
        return [
            meeting for meeting in self.meetings 
            if start_date <= meeting.created_at <= end_date
        ]
    
    async def delete_meeting(self, meeting_id: str) -> bool:
        """Delete a meeting by ID from memory"""
        for i, meeting in enumerate(self.meetings):
            if meeting.meeting_id == meeting_id:
                del self.meetings[i]
                return True
        return False 