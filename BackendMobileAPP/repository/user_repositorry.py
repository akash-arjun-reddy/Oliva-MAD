from sqlalchemy.orm import Session

from models.user import User


def get_user_by_id(db: Session, user_id: int) -> User:
    return db.query(User).filter(User.id == user_id).first()