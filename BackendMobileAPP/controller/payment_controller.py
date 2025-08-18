from fastapi import APIRouter, Request, HTTPException, status, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from database.connection import get_db
from models.order_models import PaymentTransaction, PaymentStatus, PaymentMethod
from service.payment_service import get_payment_token, create_payment_link, create_shopify_order
from utils.razorpay_utils import validate_razorpay_signature
import hmac
import hashlib
import os
from datetime import datetime
import uuid

router = APIRouter()

RAZORPAY_WEBHOOK_SECRET = os.getenv("RAZORPAY_WEBHOOK_SECRET", "your_razorpay_webhook_secret")

@router.post("/create_payment")
async def create_payment(request: Request, db: Session = Depends(get_db)):
    """Create payment link and save transaction to database"""
    try:
        payload = await request.json()
        
        # Generate payment token and link
        token = get_payment_token()
        payment_response = create_payment_link(token, payload)
        
        # Generate unique transaction ID
        transaction_id = f"TXN-{datetime.now().strftime('%Y%m%d')}-{uuid.uuid4().hex[:8].upper()}"
        
        # Save payment transaction to database
        payment_transaction = PaymentTransaction(
            transaction_id=transaction_id,
            payment_method=PaymentMethod(payload.get('payment_method', 'upi')),
            payment_gateway='razorpay',
            amount=payload.get('amount', 0),
            currency=payload.get('currency', 'INR'),
            status=PaymentStatus.PENDING,
            gateway_response=payment_response,
            gateway_transaction_id=payment_response.get('id'),
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        db.add(payment_transaction)
        db.commit()
        db.refresh(payment_transaction)
        
        # Add transaction ID to response
        payment_response['transaction_id'] = transaction_id
        
        return JSONResponse(content=payment_response)
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Payment creation failed: {str(e)}")

@router.post("/webhook")
async def razorpay_webhook(request: Request, db: Session = Depends(get_db)):
    """Handle Razorpay webhook and update payment status"""
    try:
        data = await request.body()
        received_signature = request.headers.get('X-Razorpay-Signature')
        
        if not validate_razorpay_signature(data, received_signature, RAZORPAY_WEBHOOK_SECRET):
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Signature mismatch")
        
        payload = await request.json()
        
        # Update payment transaction status
        gateway_transaction_id = payload.get('payload', {}).get('payment', {}).get('entity', {}).get('id')
        
        if gateway_transaction_id:
            payment_transaction = db.query(PaymentTransaction).filter(
                PaymentTransaction.gateway_transaction_id == gateway_transaction_id
            ).first()
            
            if payment_transaction:
                payment_transaction.status = PaymentStatus.PAID
                payment_transaction.gateway_response = payload
                payment_transaction.updated_at = datetime.utcnow()
                db.commit()
        
        # Create Shopify order
        shopify_status, shopify_response = create_shopify_order(payload)
        
        return JSONResponse(content={
            "shopify_status": shopify_status, 
            "shopify_response": shopify_response,
            "payment_updated": payment_transaction is not None
        })
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Webhook processing failed: {str(e)}")

@router.get("/transactions")
async def get_payment_transactions(db: Session = Depends(get_db)):
    """Get all payment transactions"""
    try:
        transactions = db.query(PaymentTransaction).order_by(PaymentTransaction.created_at.desc()).all()
        return {
            "success": True,
            "transactions": [
                {
                    "transaction_id": t.transaction_id,
                    "payment_method": t.payment_method.value if t.payment_method else None,
                    "amount": float(t.amount) if t.amount else 0,
                    "status": t.status.value if t.status else None,
                    "created_at": t.created_at.isoformat() if t.created_at else None,
                    "gateway_transaction_id": t.gateway_transaction_id
                }
                for t in transactions
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch transactions: {str(e)}")

@router.get("/transactions/{transaction_id}")
async def get_payment_transaction(transaction_id: str, db: Session = Depends(get_db)):
    """Get specific payment transaction"""
    try:
        transaction = db.query(PaymentTransaction).filter(
            PaymentTransaction.transaction_id == transaction_id
        ).first()
        
        if not transaction:
            raise HTTPException(status_code=404, detail="Transaction not found")
        
        return {
            "success": True,
            "transaction": {
                "transaction_id": transaction.transaction_id,
                "payment_method": transaction.payment_method.value if transaction.payment_method else None,
                "payment_gateway": transaction.payment_gateway,
                "amount": float(transaction.amount) if transaction.amount else 0,
                "currency": transaction.currency,
                "status": transaction.status.value if transaction.status else None,
                "gateway_transaction_id": transaction.gateway_transaction_id,
                "created_at": transaction.created_at.isoformat() if transaction.created_at else None,
                "updated_at": transaction.updated_at.isoformat() if transaction.updated_at else None,
                "gateway_response": transaction.gateway_response
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch transaction: {str(e)}")