from fastapi import APIRouter, HTTPException, Depends
from typing import List, Dict
from pydantic import BaseModel
from sqlalchemy.orm import Session
from database.connection import get_db
from models.order_models import Order, OrderItem, PaymentTransaction, OrderStatus, PaymentStatus, PaymentMethod
from shopify_service import shopify_service
from datetime import datetime
import uuid

router = APIRouter(prefix="/shopify", tags=["Shopify"])

class OrderItemRequest(BaseModel):
    name: str
    quantity: int
    price: str

class CustomerInfo(BaseModel):
    first_name: str
    last_name: str
    email: str
    phone: str

class ShippingAddress(BaseModel):
    address1: str
    city: str
    province: str
    country: str
    zip: str
    phone: str

class CreateOrderRequest(BaseModel):
    line_items: List[OrderItemRequest]
    customer: CustomerInfo
    shipping_address: ShippingAddress

class PaymentSuccessRequest(BaseModel):
    payment_id: str
    payment_data: Dict
    products: List[Dict]

class CreateOrderDirectlyRequest(BaseModel):
    payment_data: Dict
    products: List[Dict]
    payment_method: str

@router.get("/products")
async def get_shopify_products():
    """Get all products from Shopify"""
    try:
        products = shopify_service.get_products()
        return {"success": True, "products": products}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/create-order")
async def create_shopify_order(request: CreateOrderRequest, db: Session = Depends(get_db)):
    """Create a new order in Shopify and save to database"""
    try:
        # Generate unique order ID
        order_id = f"ORD-{datetime.now().strftime('%Y%m%d')}-{uuid.uuid4().hex[:8].upper()}"
        
        # Calculate total amount
        total_amount = sum(float(item.price) * item.quantity for item in request.line_items)
        
        # Create order in database
        order = Order(
            order_id=order_id,
            customer_id=f"CUST-{uuid.uuid4().hex[:8].upper()}",  # Generate customer ID
            order_status=OrderStatus.PENDING,
            payment_status=PaymentStatus.PENDING,
            total_amount=total_amount,
            subtotal_amount=total_amount,
            tax_amount=0,
            shipping_amount=0,
            discount_amount=0,
            shipping_address={
                "first_name": request.customer.first_name,
                "last_name": request.customer.last_name,
                "address1": request.shipping_address.address1,
                "phone": request.shipping_address.phone,
                "city": request.shipping_address.city,
                "province": request.shipping_address.province,
                "country": request.shipping_address.country,
                "zip": request.shipping_address.zip
            },
            billing_address={
                "first_name": request.customer.first_name,
                "last_name": request.customer.last_name,
                "email": request.customer.email,
                "phone": request.customer.phone
            },
            payment_method=None,  # Will be set when payment is processed
            payment_gateway=None,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        db.add(order)
        db.flush()  # Get the order ID
        
        # Create order items in database
        for item in request.line_items:
            order_item = OrderItem(
                order_id=order.id,
                product_name=item.name,
                quantity=item.quantity,
                unit_price=float(item.price),
                total_price=float(item.price) * item.quantity,
                created_at=datetime.utcnow()
            )
            db.add(order_item)
        
        # Prepare order data for Shopify
        order_data = {
            "line_items": [
                {
                    "title": item.name,
                    "price": item.price,
                    "quantity": item.quantity
                }
                for item in request.line_items
            ],
            "customer": {
                "first_name": request.customer.first_name,
                "last_name": request.customer.last_name,
                "email": request.customer.email
            },
            "shipping_address": {
                "first_name": request.customer.first_name,
                "last_name": request.customer.last_name,
                "address1": request.shipping_address.address1,
                "phone": request.shipping_address.phone,
                "city": request.shipping_address.city,
                "province": request.shipping_address.province,
                "country": request.shipping_address.country,
                "zip": request.shipping_address.zip
            }
        }
        
        # Create order in Shopify
        shopify_result = shopify_service.create_order(order_data)
        
        # Update order with Shopify order ID
        if shopify_result.get('order', {}).get('id'):
            order.shopify_order_id = str(shopify_result['order']['id'])
            order.order_status = OrderStatus.CONFIRMED
            order.payment_status = PaymentStatus.PAID
        
        db.commit()
        
        return {
            "success": True, 
            "order": shopify_result,
            "database_order_id": order_id,
            "shopify_order_id": order.shopify_order_id
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/create-order-directly")
async def create_order_directly(request: CreateOrderDirectlyRequest, db: Session = Depends(get_db)):
    """Create order directly for COD orders without payment"""
    try:
        # Generate unique order ID
        order_id = f"ORD-{datetime.now().strftime('%Y%m%d')}-{uuid.uuid4().hex[:8].upper()}"
        
        # Calculate total amount
        total_amount = sum(float(product.get('price', 0)) for product in request.products)
        
        # Create order in database
        order = Order(
            order_id=order_id,
            customer_id=f"CUST-{uuid.uuid4().hex[:8].upper()}",
            order_status=OrderStatus.CONFIRMED,  # COD orders are confirmed immediately
            payment_status=PaymentStatus.PENDING,  # Payment pending until delivery
            total_amount=total_amount,
            subtotal_amount=total_amount,
            tax_amount=0,
            shipping_amount=0,
            discount_amount=0,
            shipping_address=request.payment_data.get("address_info", {}),
            billing_address=request.payment_data.get("personal_info", {}),
            payment_method=PaymentMethod.COD,
            payment_gateway='cod',
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        db.add(order)
        db.flush()
        
        # Create order items in database
        for product in request.products:
            order_item = OrderItem(
                order_id=order.id,
                product_name=product.get('name', 'Unknown Product'),
                product_sku=product.get('sku', f"SKU-{uuid.uuid4().hex[:8].upper()}"),  # Generate SKU if not provided
                quantity=product.get('quantity', 1),
                unit_price=float(product.get('price', 0)),
                total_price=float(product.get('price', 0)) * product.get('quantity', 1),
                tax_amount=0,
                discount_amount=0,
                created_at=datetime.utcnow()
            )
            db.add(order_item)
        
        # For COD orders, we don't create Shopify order immediately
        # It will be created when payment is collected during delivery
        
        # Create Shopify order immediately for COD (with pending payment status)
        try:
            # Use a basic product variant ID that should exist in your Shopify store
            # You can replace this with actual variant IDs from your Shopify products
            order_data = {
                "line_items": [
                    {
                        "variant_id": 43910441009306,  # Brightening Moisturizer - real variant ID from your store
                        "quantity": product.get('quantity', 1)
                    }
                    for product in request.products
                ],
                "customer": {
                    "first_name": request.payment_data.get("personal_info", {}).get("first_name", ""),
                    "last_name": request.payment_data.get("personal_info", {}).get("last_name", ""),
                    "email": request.payment_data.get("personal_info", {}).get("email", "")
                },
                "shipping_address": {
                    "first_name": request.payment_data.get("personal_info", {}).get("first_name", ""),
                    "last_name": request.payment_data.get("personal_info", {}).get("last_name", ""),
                    "address1": request.payment_data.get("address_info", {}).get("address_1", ""),
                    "city": request.payment_data.get("address_info", {}).get("city", "Mumbai"),
                    "province": "Maharashtra",
                    "country": "India",
                    "zip": request.payment_data.get("address_info", {}).get("zip_code", "400001")
                }
            }
            
            print(f"Creating Shopify order with data: {order_data}")
            shopify_result = shopify_service.create_order(order_data, financial_status="pending")
            print(f"Shopify result: {shopify_result}")
            
            # Update order with Shopify order ID
            if shopify_result.get('order', {}).get('id'):
                order.shopify_order_id = str(shopify_result['order']['id'])
                db.commit()
                print(f"Shopify order created with ID: {order.shopify_order_id}")
            else:
                print(f"No Shopify order ID in result: {shopify_result}")
                
        except Exception as e:
            print(f"Failed to create Shopify order for COD: {e}")
            import traceback
            traceback.print_exc()
            # Continue with database order even if Shopify fails
        
        db.commit()
        
        return {
            "success": True,
            "message": "COD order accepted successfully",
            "database_order_id": order_id,
            "shopify_order_id": None,  # Will be created later
            "payment_method": "COD",
            "status": "confirmed"
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/payment-success")
async def handle_payment_success(request: PaymentSuccessRequest, db: Session = Depends(get_db)):
    """Handle payment success and create Shopify order with database tracking"""
    try:
        # Find payment transaction
        payment_transaction = db.query(PaymentTransaction).filter(
            PaymentTransaction.transaction_id == request.payment_id
        ).first()
        
        if not payment_transaction:
            # Create a new payment transaction if not found
            payment_transaction = PaymentTransaction(
                transaction_id=request.payment_id,
                payment_method=PaymentMethod.UPI,  # Default
                payment_gateway='razorpay',
                amount=sum(float(product.get('price', 0)) for product in request.products),
                currency='INR',
                status=PaymentStatus.PAID,
                gateway_response=request.payment_data,
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow()
            )
            db.add(payment_transaction)
            db.flush()
        
        # Generate unique order ID
        order_id = f"ORD-{datetime.now().strftime('%Y%m%d')}-{uuid.uuid4().hex[:8].upper()}"
        
        # Calculate total amount
        total_amount = sum(float(product.get('price', 0)) for product in request.products)
        
        # Create order in database
        order = Order(
            order_id=order_id,
            customer_id=f"CUST-{uuid.uuid4().hex[:8].upper()}",
            order_status=OrderStatus.CONFIRMED,
            payment_status=PaymentStatus.PAID,
            total_amount=total_amount,
            subtotal_amount=total_amount,
            tax_amount=0,
            shipping_amount=0,
            discount_amount=0,
            shipping_address=request.payment_data.get("address_info", {}),
            billing_address=request.payment_data.get("personal_info", {}),
            payment_method=payment_transaction.payment_method,
            payment_gateway=payment_transaction.payment_gateway,
            payment_transaction_id=payment_transaction.transaction_id,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        db.add(order)
        db.flush()
        
        # Create order items in database
        for product in request.products:
            order_item = OrderItem(
                order_id=order.id,
                product_name=product.get('name', 'Unknown Product'),
                quantity=product.get('quantity', 1),
                unit_price=float(product.get('price', 0)),
                total_price=float(product.get('price', 0)) * product.get('quantity', 1),
                created_at=datetime.utcnow()
            )
            db.add(order_item)
        
        # Create order from payment data
        order_data = {
            "products": request.products,
            "personal_info": request.payment_data.get("personal_info", {}),
            "address_info": request.payment_data.get("address_info", {})
        }
        
        # Create Shopify order
        shopify_result = shopify_service.create_order_from_payment(order_data)
        
        # Update order with Shopify order ID
        if shopify_result.get('order', {}).get('id'):
            order.shopify_order_id = str(shopify_result['order']['id'])
        
        db.commit()
        
        return {
            "success": True,
            "message": "Order created successfully in Shopify",
            "order": shopify_result,
            "payment_id": request.payment_id,
            "database_order_id": order_id,
            "shopify_order_id": order.shopify_order_id
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/fulfill-order/{order_id}")
async def fulfill_order(order_id: int, db: Session = Depends(get_db)):
    """Mark an order as fulfilled"""
    try:
        # Update database order status
        order = db.query(Order).filter(Order.shopify_order_id == str(order_id)).first()
        if order:
            order.order_status = OrderStatus.SHIPPED
            order.updated_at = datetime.utcnow()
            db.commit()
        
        # Fulfill in Shopify
        result = shopify_service.fulfill_order(order_id)
        return {"success": True, "fulfillment": result}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/order/{order_id}")
async def get_order(order_id: int, db: Session = Depends(get_db)):
    """Get order details from database and Shopify"""
    try:
        # Get from database
        db_order = db.query(Order).filter(Order.shopify_order_id == str(order_id)).first()
        
        # Get from Shopify
        shopify_order = shopify_service.get_order(order_id)
        
        return {
            "success": True, 
            "database_order": {
                "order_id": db_order.order_id if db_order else None,
                "status": db_order.order_status.value if db_order else None,
                "payment_status": db_order.payment_status.value if db_order else None,
                "total_amount": float(db_order.total_amount) if db_order and db_order.total_amount else 0,
                "created_at": db_order.created_at.isoformat() if db_order and db_order.created_at else None
            },
            "shopify_order": shopify_order
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/orders")
async def get_all_orders(db: Session = Depends(get_db)):
    """Get all orders from database"""
    try:
        orders = db.query(Order).order_by(Order.created_at.desc()).all()
        return {
            "success": True,
            "orders": [
                {
                    "order_id": order.order_id,
                    "shopify_order_id": order.shopify_order_id,
                    "status": order.order_status.value if order.order_status else None,
                    "payment_status": order.payment_status.value if order.payment_status else None,
                    "total_amount": float(order.total_amount) if order.total_amount else 0,
                    "created_at": order.created_at.isoformat() if order.created_at else None,
                    "customer_id": order.customer_id
                }
                for order in orders
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/test-connection")
async def test_shopify_connection():
    """Test Shopify API connection"""
    try:
        products = shopify_service.get_products()
        return {
            "success": True,
            "message": "Shopify connection successful",
            "product_count": len(products)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Shopify connection failed: {str(e)}") 