from sqlalchemy import Column, Integer, String, DateTime, DECIMAL, JSON, Enum, ForeignKey, Text
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from database.connection import Base

class OrderStatus(enum.Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    PROCESSING = "processing"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"
    RETURNED = "returned"

class PaymentStatus(enum.Enum):
    PENDING = "pending"
    PAID = "paid"
    FAILED = "failed"
    REFUNDED = "refunded"
    PARTIALLY_REFUNDED = "partially_refunded"

class PaymentMethod(enum.Enum):
    UPI = "upi"
    CREDIT_CARD = "credit_card"
    DEBIT_CARD = "debit_card"
    NET_BANKING = "net_banking"
    WALLET = "wallet"
    COD = "cod"

class Order(Base):
    __tablename__ = "orders"
    
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(String(50), unique=True, index=True)  # External order ID
    customer_id = Column(String(50), index=True)
    shopify_order_id = Column(String(50), nullable=True)  # Shopify order ID
    
    # Order details
    order_status = Column(Enum(OrderStatus), default=OrderStatus.PENDING)
    payment_status = Column(Enum(PaymentStatus), default=PaymentStatus.PENDING)
    total_amount = Column(DECIMAL(10, 2))
    subtotal_amount = Column(DECIMAL(10, 2))
    tax_amount = Column(DECIMAL(10, 2))
    shipping_amount = Column(DECIMAL(10, 2))
    discount_amount = Column(DECIMAL(10, 2))
    
    # Address information
    shipping_address = Column(JSON)
    billing_address = Column(JSON)
    
    # Payment information
    payment_method = Column(Enum(PaymentMethod))
    payment_gateway = Column(String(50))
    payment_transaction_id = Column(String(100), nullable=True)
    
    # Shipping information
    tracking_number = Column(String(100), nullable=True)
    estimated_delivery_date = Column(DateTime, nullable=True)
    actual_delivery_date = Column(DateTime, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    items = relationship("OrderItem", back_populates="order")
    payments = relationship("PaymentTransaction", back_populates="order")
    events = relationship("OrderEvent", back_populates="order")

class OrderItem(Base):
    __tablename__ = "order_items"
    
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"))
    product_id = Column(String(50), index=True)
    variant_id = Column(String(50), nullable=True)
    shopify_variant_id = Column(String(50), nullable=True)
    
    # Product details
    product_name = Column(String(255))
    product_sku = Column(String(100))
    quantity = Column(Integer)
    unit_price = Column(DECIMAL(10, 2))
    total_price = Column(DECIMAL(10, 2))
    tax_amount = Column(DECIMAL(10, 2))
    discount_amount = Column(DECIMAL(10, 2))
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    order = relationship("Order", back_populates="items")

class PaymentTransaction(Base):
    __tablename__ = "payment_transactions"
    
    id = Column(Integer, primary_key=True, index=True)
    transaction_id = Column(String(100), unique=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"))
    
    # Payment details
    payment_method = Column(Enum(PaymentMethod))
    payment_gateway = Column(String(50))
    amount = Column(DECIMAL(10, 2))
    currency = Column(String(3), default="INR")
    status = Column(Enum(PaymentStatus))
    
    # Gateway response
    gateway_response = Column(JSON)
    gateway_transaction_id = Column(String(100), nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    order = relationship("Order", back_populates="payments")

class OrderEvent(Base):
    __tablename__ = "order_events"
    
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"))
    
    # Event details
    event_type = Column(String(50))  # order.created, payment.success, etc.
    event_data = Column(JSON)
    description = Column(Text)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    order = relationship("Order", back_populates="events")

class Customer(Base):
    __tablename__ = "customers"
    
    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(String(50), unique=True, index=True)
    
    # Personal information
    first_name = Column(String(100))
    last_name = Column(String(100))
    email = Column(String(255), unique=True, index=True)
    phone = Column(String(20))
    
    # Address information
    default_shipping_address = Column(JSON, nullable=True)
    default_billing_address = Column(JSON, nullable=True)
    
    # Account information
    is_active = Column(Integer, default=1)
    total_orders = Column(Integer, default=0)
    total_spent = Column(DECIMAL(10, 2), default=0)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Product(Base):
    __tablename__ = "products"
    
    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(String(50), unique=True, index=True)
    shopify_product_id = Column(String(50), nullable=True)
    
    # Product details
    name = Column(String(255))
    description = Column(Text, nullable=True)
    sku = Column(String(100), unique=True)
    price = Column(DECIMAL(10, 2))
    compare_at_price = Column(DECIMAL(10, 2), nullable=True)
    
    # Inventory
    inventory_quantity = Column(Integer, default=0)
    inventory_policy = Column(String(50), default="deny")  # deny, continue
    
    # Status
    is_active = Column(Integer, default=1)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class InventoryLog(Base):
    __tablename__ = "inventory_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(String(50), index=True)
    
    # Inventory change
    change_type = Column(String(50))  # order_placed, order_cancelled, manual_adjustment
    quantity_change = Column(Integer)  # negative for reduction, positive for addition
    previous_quantity = Column(Integer)
    new_quantity = Column(Integer)
    
    # Reference
    order_id = Column(String(50), nullable=True)
    reference_id = Column(String(100), nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow) 