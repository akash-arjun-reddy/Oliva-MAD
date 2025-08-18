from sqlalchemy import text
import logging
from fastapi import HTTPException
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from models.user import User

logger = logging.getLogger(__name__)

class GuestDataService:
    def __init__(self, db: Session, zenoti_db: Session):
        self.db = db
        self.zenoti_db = zenoti_db

    def get_guest_code_by_user_id(self, users_id: int) -> str:
        try:
            user = (
                self.db.query(User)
                .filter(User.id == users_id)
                .first()
            )

            if not user:
                logger.warning(f"User with id={users_id} not found")
                raise HTTPException(status_code=404, detail="User not found")

            if not user.guest_code:
                logger.warning(f"User with id={users_id} has no guest_code")
                raise HTTPException(status_code=400, detail="User has no guest_code")

            guest_code = user.guest_code.strip().lower()
            logger.info(f"Found user id={users_id}, normalized guest_code='{guest_code}'")
            return guest_code

        except SQLAlchemyError as e:
            logger.error(f"DB error while fetching user: {e}")
            raise HTTPException(status_code=500, detail="Internal server error")

    def get_spa_collection_by_guest_code(self, guest_code: str):
        try:
            cleaned_guest_code = guest_code.strip().lower()
            logger.info(f"Fetching spa_collection records for guest_code='{cleaned_guest_code}'")

            sql = text("""
                SELECT * FROM test.spa_collection
                WHERE LOWER(TRIM(guestcode)) = :guest_code
            """)

            result = self.zenoti_db.execute(sql, {"guest_code": cleaned_guest_code})
            records = [dict(row._mapping) for row in result.fetchall()]

            if not records:
                logger.warning(f"No spa_collection found for guest_code='{cleaned_guest_code}'")
                raise HTTPException(status_code=404, detail="No spa collections found for guest")

            logger.info(f"Found {len(records)} spa_collection record(s) for guest_code='{cleaned_guest_code}'")
            return records

        except SQLAlchemyError as e:
            logger.error(f"DB error while fetching spa_collection: {e}")
            raise HTTPException(status_code=500, detail="Internal server error")

    def get_investigations_by_guest_code(self, guest_code: str):
        try:
            cleaned_guest_code = guest_code.strip().lower()
            logger.info(f"Fetching investigations for guest_code='{cleaned_guest_code}'")

            sql = text("""
                SELECT * FROM test.spa_collection
                WHERE LOWER(TRIM(guestcode)) = :guest_code AND LOWER(TRIM(category)) = 'investigations'
            """)

            result = self.zenoti_db.execute(sql, {"guest_code": cleaned_guest_code})
            records = [dict(row._mapping) for row in result.fetchall()]

            if not records:
                logger.warning(f"No investigations found for guest_code='{cleaned_guest_code}'")
                raise HTTPException(status_code=404, detail="No investigations found for guest")

            logger.info(f"Found {len(records)} investigation record(s) for guest_code='{cleaned_guest_code}'")
            return records

        except SQLAlchemyError as e:
            logger.error(f"DB error while fetching investigations: {e}")
            raise HTTPException(status_code=500, detail="Internal server error")

    def get_sales_by_guest_code(self, guest_code: str):
        try:
            cleaned_guest_code = guest_code.strip().lower()
            logger.info(f"Fetching sales for guest_guest_code='{cleaned_guest_code}'")

            sql = text("""
                SELECT * FROM test.center_sales_report
                WHERE LOWER(TRIM(guest_guest_code)) = :guest_code
            """)

            result = self.zenoti_db.execute(sql, {"guest_code": cleaned_guest_code})
            records = [dict(row._mapping) for row in result.fetchall()]

            if not records:
                logger.warning(f"No sales found for guest_guest_code='{cleaned_guest_code}'")
                raise HTTPException(status_code=404, detail="No sales found for guest")

            logger.info(f"Found {len(records)} sales record(s) for guest_guest_code='{cleaned_guest_code}'")
            return records

        except SQLAlchemyError as e:
            logger.error(f"DB error while fetching sales: {e}")
            raise HTTPException(status_code=500, detail="Internal server error")
