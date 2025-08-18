# BackendMobileAPP/constants/status_codes.py

STATUS_MAP = {
    "Scheduled": 0,
    "Completed": 1,
    "Cancelled": 2,
    "No-Show": 3
}

REVERSE_STATUS_MAP = {v: k for k, v in STATUS_MAP.items()}
