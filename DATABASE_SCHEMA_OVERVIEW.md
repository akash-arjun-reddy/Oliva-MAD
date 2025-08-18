# 🗄️ Database Schema Overview

## 📊 **Complete Database Tables**

Your database now contains the following tables for the complete e-commerce and clinic management system:

---

## 🛒 **E-COMMERCE TABLES (NEWLY ADDED)**

### **1. `orders` Table**
```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_id VARCHAR(50) UNIQUE,           -- Internal order ID (e.g., ORD-20240804-ABC123)
    customer_id VARCHAR(50),               -- Customer identifier
    shopify_order_id VARCHAR(50),          -- Shopify order ID (external)
    
    -- Order Status
    order_status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'returned'),
    payment_status ENUM('pending', 'paid', 'failed', 'refunded', 'partially_refunded'),
    
    -- Financial Details
    total_amount DECIMAL(10,2),
    subtotal_amount DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    shipping_amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    
    -- Address Information (JSON)
    shipping_address JSON,                 -- Customer shipping address
    billing_address JSON,                  -- Customer billing address
    
    -- Payment Information
    payment_method ENUM('upi', 'credit_card', 'debit_card', 'net_banking', 'wallet', 'cod'),
    payment_gateway VARCHAR(50),           -- 'razorpay', 'stripe', etc.
    payment_transaction_id VARCHAR(100),   -- Links to payment_transactions
    
    -- Shipping Information
    tracking_number VARCHAR(100),
    estimated_delivery_date TIMESTAMP,
    actual_delivery_date TIMESTAMP,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### **2. `order_items` Table**
```sql
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    
    -- Product Identifiers
    product_id VARCHAR(50),
    variant_id VARCHAR(50),
    shopify_variant_id VARCHAR(50),
    
    -- Product Details
    product_name VARCHAR(255),
    product_sku VARCHAR(100),
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    total_price DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW()
);
```

### **3. `payment_transactions` Table**
```sql
CREATE TABLE payment_transactions (
    id SERIAL PRIMARY KEY,
    transaction_id VARCHAR(100) UNIQUE,    -- Internal transaction ID (e.g., TXN-20240804-ABC123)
    order_id INTEGER REFERENCES orders(id),
    
    -- Payment Details
    payment_method ENUM('upi', 'credit_card', 'debit_card', 'net_banking', 'wallet', 'cod'),
    payment_gateway VARCHAR(50),           -- 'razorpay', 'stripe', etc.
    amount DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'INR',
    status ENUM('pending', 'paid', 'failed', 'refunded', 'partially_refunded'),
    
    -- Gateway Information
    gateway_response JSON,                 -- Complete gateway response
    gateway_transaction_id VARCHAR(100),   -- External gateway transaction ID
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### **4. `order_events` Table**
```sql
CREATE TABLE order_events (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    
    -- Event Details
    event_type VARCHAR(50),               -- 'order.created', 'payment.success', 'order.shipped'
    event_data JSON,                      -- Event-specific data
    description TEXT,                     -- Human-readable description
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW()
);
```

### **5. `customers` Table**
```sql
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) UNIQUE,       -- Customer identifier
    
    -- Personal Information
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    
    -- Address Information (JSON)
    default_shipping_address JSON,
    default_billing_address JSON,
    
    -- Account Statistics
    is_active INTEGER DEFAULT 1,
    total_orders INTEGER DEFAULT 0,
    total_spent DECIMAL(10,2) DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### **6. `products` Table**
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    product_id VARCHAR(50) UNIQUE,
    shopify_product_id VARCHAR(50),
    
    -- Product Details
    name VARCHAR(255),
    description TEXT,
    sku VARCHAR(100) UNIQUE,
    price DECIMAL(10,2),
    compare_at_price DECIMAL(10,2),
    
    -- Inventory
    inventory_quantity INTEGER DEFAULT 0,
    inventory_policy VARCHAR(50) DEFAULT 'deny',
    
    -- Status
    is_active INTEGER DEFAULT 1,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### **7. `inventory_logs` Table**
```sql
CREATE TABLE inventory_logs (
    id SERIAL PRIMARY KEY,
    product_id VARCHAR(50),
    
    -- Inventory Change
    change_type VARCHAR(50),              -- 'order_placed', 'order_cancelled', 'manual_adjustment'
    quantity_change INTEGER,              -- Negative for reduction, positive for addition
    previous_quantity INTEGER,
    new_quantity INTEGER,
    
    -- Reference
    order_id VARCHAR(50),
    reference_id VARCHAR(100),
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🏥 **CLINIC MANAGEMENT TABLES (EXISTING)**

### **8. `users` Table**
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(255) UNIQUE,
    hashed_password VARCHAR(255),
    full_name VARCHAR(100),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### **9. `appointments` Table**
```sql
CREATE TABLE appointments (
    id SERIAL PRIMARY KEY,
    appointment_id VARCHAR(50) UNIQUE,
    patient_id INTEGER,
    doctor_id INTEGER,
    date DATE,
    start_time TIME,
    end_time TIME,
    status VARCHAR(20),
    video_call_link VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);
```

### **10. `bookings` Table**
```sql
CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    booking_id VARCHAR(50) UNIQUE,
    customer_name VARCHAR(100),
    customer_email VARCHAR(255),
    customer_phone VARCHAR(20),
    service_type VARCHAR(100),
    appointment_date DATE,
    appointment_time TIME,
    status VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW()
);
```

### **11. `otp` Table**
```sql
CREATE TABLE otp (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255),
    otp_code VARCHAR(6),
    is_used BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### **12. `login_logs` Table**
```sql
CREATE TABLE login_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    login_time TIMESTAMP DEFAULT NOW(),
    ip_address VARCHAR(45),
    user_agent TEXT,
    success BOOLEAN
);
```

---

## 🔗 **Table Relationships**

### **E-Commerce Relationships:**
```
orders (1) ←→ (many) order_items
orders (1) ←→ (many) payment_transactions
orders (1) ←→ (many) order_events
customers (1) ←→ (many) orders
products (1) ←→ (many) order_items
```

### **Clinic Relationships:**
```
users (1) ←→ (many) appointments
users (1) ←→ (many) login_logs
```

---

## 📊 **Sample Data Queries**

### **View All Orders:**
```sql
SELECT 
    o.order_id,
    o.customer_id,
    o.total_amount,
    o.order_status,
    o.payment_status,
    o.created_at
FROM orders o
ORDER BY o.created_at DESC;
```

### **View Payment Transactions:**
```sql
SELECT 
    pt.transaction_id,
    pt.payment_method,
    pt.amount,
    pt.status,
    pt.created_at
FROM payment_transactions pt
ORDER BY pt.created_at DESC;
```

### **View Order with Items:**
```sql
SELECT 
    o.order_id,
    o.total_amount,
    oi.product_name,
    oi.quantity,
    oi.unit_price
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
WHERE o.order_id = 'ORD-20240804-ABC123';
```

### **Revenue Analytics:**
```sql
SELECT 
    DATE(created_at) as date,
    COUNT(*) as orders,
    SUM(total_amount) as revenue
FROM orders 
WHERE payment_status = 'paid'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

---

## 🎯 **Key Features of Your Database:**

1. **Complete E-Commerce Tracking**: Orders, payments, customers, products
2. **Payment Integration**: Razorpay transactions with full audit trail
3. **Shopify Sync**: Orders created in Shopify with database tracking
4. **Inventory Management**: Product inventory with change logs
5. **Customer Management**: Customer profiles with order history
6. **Clinic Management**: Appointments, bookings, user management
7. **Security**: OTP verification, login logs, user authentication

---

## ✅ **Database Status:**

- ✅ **All tables created successfully**
- ✅ **Foreign key relationships established**
- ✅ **Indexes created for performance**
- ✅ **Enums defined for status fields**
- ✅ **JSON fields for flexible data storage**
- ✅ **Timestamps for audit trail**

Your database is now ready for complete e-commerce and clinic management operations! 