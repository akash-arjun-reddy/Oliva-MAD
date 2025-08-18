from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from typing import Optional
from fastapi import Query

from database.session import get_db
from models.user import User
from security.jwt import get_current_user
from service.loyalty_service import fetch_loyalty_points, fetch_loyalty_points_by_type

from utils.logger import get_logger

router = APIRouter()
logger = get_logger()

@router.get("/guests/{guest_id}/loyalty-points", tags=["Loyalty"])
async def get_loyalty_points(
    guest_id: str,
    page_num: Optional[int] = None,
    num_records: Optional[int] = None,
    sort_ascending: Optional[bool] = None,
    view_grooming_points: Optional[bool] = None,
    expand: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    #  Check if the guest_id belongs to the logged-in user
    if current_user.guest_id != guest_id:
        logger.warning(f"[LOYALTY] Unauthorized guest_id access by user_id={current_user.id}")
        raise HTTPException(status_code=403, detail="Unauthorized: guest_id does not belong to you")

    result = await fetch_loyalty_points(
        guest_id=guest_id,
        page_num=page_num,
        num_records=num_records,
        sort_ascending=sort_ascending,
        view_grooming_points=view_grooming_points,
        expand=expand,
        db=db
    )
    return result


@router.get("/guests/{guest_id}/points/{type}", tags=["Loyalty"])
async def get_loyalty_points_by_type(
    guest_id: str,
    type: int,  # 0 = earned, 1 = redeemed
    invoice_id: str = Query(...),
    current_user: User = Depends(get_current_user)
):
    if current_user.guest_id != guest_id:
        raise HTTPException(status_code=403, detail="Unauthorized: guest_id mismatch")

    return await fetch_loyalty_points_by_type(guest_id, type, invoice_id)