from .connection import SessionLocal, ZenotiSessionLocal


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_zenoti_db():
    db = ZenotiSessionLocal()
    try:
        yield db
    finally:
        db.close()