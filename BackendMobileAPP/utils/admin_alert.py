import logging

def send_alert_to_admin(message: str):
    logger = logging.getLogger("uvicorn.error")
    logger.warning(f"📣 ADMIN ALERT: {message}")
