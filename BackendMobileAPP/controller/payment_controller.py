from fastapi import APIRouter, Request, HTTPException, status
from fastapi.responses import JSONResponse
# Fix the import paths by adding BackendMobileAPP prefix
from service.payment_service import get_payment_token, create_payment_link, create_shopify_order
from utils.razorpay_utils import validate_razorpay_signature
import hmac
import hashlib
import os

router = APIRouter()

RAZORPAY_WEBHOOK_SECRET = os.getenv("RAZORPAY_WEBHOOK_SECRET", "your_razorpay_webhook_secret")

@router.post("/create_payment")
async def create_payment(request: Request):
    payload = await request.json()
    token = get_payment_token()
    payment_response = create_payment_link(token, payload)
    return JSONResponse(content=payment_response)

@router.post("/webhook")
async def razorpay_webhook(request: Request):
    data = await request.body()
    received_signature = request.headers.get('X-Razorpay-Signature')
    if not validate_razorpay_signature(data, received_signature, RAZORPAY_WEBHOOK_SECRET):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Signature mismatch")
    payload = await request.json()
    # You can check event type here if needed
    # if payload.get('event') == 'payment_link.paid':
    shopify_status, shopify_response = create_shopify_order(payload)
    return JSONResponse(content={"shopify_status": shopify_status, "shopify_response": shopify_response})