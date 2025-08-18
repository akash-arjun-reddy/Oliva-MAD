import hmac
import hashlib

def validate_razorpay_signature(data: bytes, received_signature: str, secret: str) -> bool:
    generated_signature = hmac.new(
        bytes(secret, 'utf-8'),
        msg=data,
        digestmod=hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(received_signature, generated_signature) 