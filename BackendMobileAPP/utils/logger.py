import logging

# Configure logger for your app only
logger = logging.getLogger('mobileAppBackend')
logger.setLevel(logging.DEBUG)

# Create console handler
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)

# Formatter for log messages
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
console_handler.setFormatter(formatter)

# Add handler if not already present
if not logger.hasHandlers():
    logger.addHandler(console_handler)

def get_logger():
    return logger
