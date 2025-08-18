# 🏦 Complete Payment Flow Documentation

## 📊 **Payment Flow Overview**

```
User selects products → Payment page → Payment method selection → 
Payment link generation → External payment → Payment success → 
Shopify order creation → Database storage → Order tracking
```

## 🔄 **Step-by-Step Flow**

### **Step 1: Payment Link Generation**
- **Frontend**: User selects payment method (UPI/Card/Wallet)
- **Backend**: `POST /create_payment` endpoint
- **Database**: ✅ **SAVED** - Payment transaction stored in `payment_transactions` table
- **External**: Calls `https://payments.olivaclinic.com/api/payment`

**Database Storage:**
```sql
INSERT INTO payment_transactions (
    transaction_id, payment_method, payment_gateway, 
    amount, currency, status, gateway_response
) VALUES (
    'TXN-20240804-ABC123', 'upi', 'razorpay', 
    1000.00, 'INR', 'pending', {...}
);
```

### **Step 2: Payment Completion**
- **User**: Completes payment externally via payment link
- **Gateway**: Sends webhook to `POST /webhook` endpoint
- **Database**: ✅ **UPDATED** - Payment status changed to 'paid'
- **Shopify**: Order created in Shopify admin

### **Step 3: Order Creation**
- **Frontend**: User clicks "Create Order" button
- **Backend**: `POST /shopify/payment-success` endpoint
- **Database**: ✅ **SAVED** - Order stored in `orders` and `order_items` tables
- **Shopify**: Order created with customer details

## 🗄️ **Database Schema**

### **Payment Transactions Table**
```sql
CREATE TABLE payment_transactions (
    id SERIAL PRIMARY KEY,
    transaction_id VARCHAR(100) UNIQUE,
    payment_method ENUM('upi', 'card', 'wallet'),
    payment_gateway VARCHAR(50),
    amount DECIMAL(10,2),
    currency VARCHAR(3),
    status ENUM('pending', 'paid', 'failed'),
    gateway_response JSON,
    gateway_transaction_id VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

### **Orders Table**
```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_id VARCHAR(50) UNIQUE,
    customer_id VARCHAR(50),
    shopify_order_id VARCHAR(50),
    order_status ENUM('pending', 'confirmed', 'shipped', 'delivered'),
    payment_status ENUM('pending', 'paid'),
    total_amount DECIMAL(10,2),
    shipping_address JSON,
    billing_address JSON,
    payment_transaction_id VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

### **Order Items Table**
```sql
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    product_name VARCHAR(255),
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    total_price DECIMAL(10,2),
    created_at TIMESTAMP
);
```

## 🔧 **Backend API Endpoints**

### **Payment Endpoints**
```bash
# Create payment link
POST /create_payment
{
    "amount": 1000,
    "currency": "INR",
    "payment_method": "upi",
    "description": "Order payment"
}

# Get all transactions
GET /transactions

# Get specific transaction
GET /transactions/{transaction_id}

# Handle webhook
POST /webhook
```

### **Shopify Endpoints**
```bash
# Test connection
GET /shopify/test-connection

# Create order
POST /shopify/create-order

# Handle payment success
POST /shopify/payment-success

# Get all orders
GET /shopify/orders

# Get specific order
GET /shopify/order/{order_id}

# Fulfill order
POST /shopify/fulfill-order/{order_id}
```

## 📱 **Frontend Integration**

### **Payment Page Flow**
```dart
// 1. Generate payment link
final paymentResponse = await PaymentService.createPayment(paymentData);

// 2. Show payment link to user
showPaymentDialog(paymentResponse['short_url']);

// 3. After payment completion, create Shopify order
final result = await ShopifyApiService.handlePaymentSuccess(
    paymentId: paymentResponse['transaction_id'],
    paymentData: paymentData,
    products: products,
);
```

### **Updated ShopifyApiService**
```dart
class ShopifyApiService {
  static Future<Map<String, dynamic>> handlePaymentSuccess({
    required String paymentId,
    required Map<String, dynamic> paymentData,
    required List<Map<String, dynamic>> products,
  }) async {
    final baseUrl = await Env.baseUrl; // Dynamic URL detection
    final response = await http.post(
      Uri.parse('$baseUrl/shopify/payment-success'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'payment_id': paymentId,
        'payment_data': paymentData,
        'products': products,
      }),
    );
    
    return json.decode(response.body);
  }
}
```

## 🔍 **Data Tracking**

### **What Gets Saved to Database:**

1. **Payment Transactions**:
   - ✅ Transaction ID
   - ✅ Payment method (UPI/Card/Wallet)
   - ✅ Amount and currency
   - ✅ Gateway response
   - ✅ Status (pending/paid/failed)

2. **Orders**:
   - ✅ Order ID (internal)
   - ✅ Shopify Order ID (external)
   - ✅ Customer details
   - ✅ Shipping address
   - ✅ Payment status
   - ✅ Order status

3. **Order Items**:
   - ✅ Product details
   - ✅ Quantity and pricing
   - ✅ Line item totals

### **What Gets Created in Shopify:**
- ✅ Customer record
- ✅ Order with line items
- ✅ Shipping address
- ✅ Payment status (paid)
- ✅ Order status (confirmed)

## 🚀 **Testing the Integration**

### **Run Test Script**
```bash
cd MAD/BackendMobileAPP
python test_payment_flow.py
```

### **Manual Testing**
```bash
# Test payment creation
curl -X POST http://localhost:8000/create_payment \
  -H "Content-Type: application/json" \
  -d '{"amount": 1000, "payment_method": "upi"}'

# Test Shopify connection
curl http://localhost:8000/shopify/test-connection

# Test payment success
curl -X POST http://localhost:8000/shopify/payment-success \
  -H "Content-Type: application/json" \
  -d '{"payment_id": "test123", "products": [{"name": "Test", "price": "100"}]}'
```

## 📊 **Monitoring & Analytics**

### **Database Queries for Analytics**
```sql
-- Total payments by status
SELECT status, COUNT(*) as count, SUM(amount) as total
FROM payment_transactions 
GROUP BY status;

-- Orders by status
SELECT order_status, COUNT(*) as count
FROM orders 
GROUP BY order_status;

-- Revenue by date
SELECT DATE(created_at) as date, SUM(total_amount) as revenue
FROM orders 
WHERE payment_status = 'paid'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

## 🔐 **Security Features**

1. **Webhook Validation**: Razorpay signature verification
2. **Database Transactions**: ACID compliance for data integrity
3. **Error Handling**: Comprehensive error catching and logging
4. **Input Validation**: Pydantic models for request validation

## 🎯 **Benefits of Database Integration**

1. **Complete Audit Trail**: Every payment and order is tracked
2. **Analytics**: Revenue, conversion rates, payment methods
3. **Reconciliation**: Match payments with orders
4. **Customer Support**: Full transaction history
5. **Compliance**: Financial record keeping
6. **Debugging**: Easy to trace payment issues

## ✅ **Status Summary**

- ✅ **Payment Link Generation**: Working with database storage
- ✅ **Payment Tracking**: All transactions saved to database
- ✅ **Shopify Integration**: Orders created in Shopify
- ✅ **Database Storage**: Complete order and payment tracking
- ✅ **Backend Server**: Running on localhost:8000
- ✅ **Error Handling**: Comprehensive error management
- ✅ **API Documentation**: Complete endpoint documentation

## 🚨 **Troubleshooting**

### **Common Issues:**

1. **"Connection refused"**: Backend server not running
   ```bash
   cd MAD/BackendMobileAPP && python main.py
   ```

2. **Database errors**: Check PostgreSQL connection
   ```bash
   # Verify database is running
   psql -h localhost -U mobileapp -d mobileapp
   ```

3. **Shopify API errors**: Check access token
   ```bash
   # Test Shopify connection
   curl http://localhost:8000/shopify/test-connection
   ```

4. **Payment link errors**: Check external payment API
   ```bash
   # Test payment creation
   curl -X POST http://localhost:8000/create_payment \
     -H "Content-Type: application/json" \
     -d '{"amount": 100, "payment_method": "upi"}'
   ```

---

**🎉 Your payment system is now fully integrated with database tracking!** 