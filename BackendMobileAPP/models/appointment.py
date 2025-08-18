from sqlalchemy import (
    Column, String, Boolean, DateTime, Float, BigInteger,
    Date, Time, Integer, ForeignKey
)
from sqlalchemy.orm import relationship

from database.base import Base



class Appointment(Base):
    __tablename__ = "appointments"
    __table_args__ = {"schema": "public", "extend_existing": True}

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    appointment_id = Column(String, unique=True, index=True)
    appointment_segment_id = Column(String)
    appointment_group_id = Column(String)
    invoice_id = Column(String)
    service_id = Column(String)
    service_segment_id = Column(String)
    service_name = Column(String)
    service_is_addon = Column(Boolean)
    service_has_addons = Column(Boolean)
    service_parent_appointment_id = Column(Float)
    service_business_unit_guid = Column(String)
    service_business_unit_id = Column(Float)
    service_business_unit_name = Column(String)
    service_category_id = Column(String)
    service_category_name = Column(String)
    service_sub_category_id = Column(String)
    service_sub_category_name = Column(String)
    service_override_default_product_consumption = Column(Boolean)
    service_override_product_consumption = Column(Boolean)
    service_is_virtual_service = Column(Boolean)
    start_time_utc = Column(String)
    end_time_utc = Column(String)
    status = Column(BigInteger)
    has_active_membership_for_auto_pay = Column(Boolean)
    guest_id = Column(String, index=True)
    therapist_id = Column(String)
    therapist_first_name = Column(String)
    therapist_last_name = Column(String)
    therapist_email = Column(String)
    room_id = Column(String)
    room_name = Column(String)
    notes = Column(String)
    group_notes = Column(Float)
    price_sales = Column(Float)
    checkin_time = Column(String)
    form_id = Column(String)
    creation_date_utc = Column(String)
    created_by_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    closed_by_id = Column(String)
    cancel_or_no_show_status = Column(BigInteger)
    invoice_item_id = Column(String)
    appointment_type = Column(BigInteger)
    center_id = Column(String)
    is_active = Column(Boolean)
    dq_check_remark = Column(String)
    inserted_date_time = Column(DateTime)
    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)
    video_call_link = Column(String, nullable=True)
    date = Column(Date, nullable=False)

    # Foreign keys to users table
    patient_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    doctor_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    # Use only the class name 'User' in relationship strings
    patient = relationship("User", foreign_keys=[patient_id], backref="appointments_as_patient")
    doctor = relationship("User", foreign_keys=[doctor_id], backref="appointments_as_doctor")
    created_by = relationship("User", foreign_keys=[created_by_id], backref="appointments_created")

class AppointmentWalkin(Base):
    __tablename__ = "appointments_walkin"
    __table_args__ = {"schema": "public", "extend_existing": True}

    appointment_id = Column(String, primary_key=True, index=True)
    mobilenumber = Column(BigInteger)
    date1 = Column(Date)
    status = Column(String)
    therapistnameval = Column(String)
    centernamelist = Column(String)
    olivadoctorrecommendations1 = Column(String)
    olivadoctorrecommendations2 = Column(String)
    olivadoctorrecommendations3 = Column(String)
    olivadoctorrecommendations4 = Column(String)
    olivadoctorrecommendations5 = Column(String)
    olivadoctorrecommendations6 = Column(String)
    olivadoctorrecommendations7 = Column(String)
    olivadoctorrecommendations8 = Column(String)
    is_active = Column(Boolean)
    dq_check_remark = Column(String)
    is_convert = Column(Boolean)
    is_recommended = Column(Boolean)
    recommendations = Column(String)
    crt_name = Column(String)
    inserted_date_time = Column(DateTime)
