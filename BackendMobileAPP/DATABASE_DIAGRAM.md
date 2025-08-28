# Database Relationship Diagram

## 🔐 **AUTHENTICATION & SECURITY LAYER**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│      users      │    │  refresh_tokens  │    │ enhanced_user_sessions │
├─────────────────┤    ├──────────────────┤    ├─────────────────────┤
│ id (PK)         │◄───┤ user_id (FK)     │    │ id (PK)             │
│ username        │    │ token_hash       │    │ user_id (FK)        │
│ email           │    │ expires_at       │    │ session_id          │
│ hashed_password │    │ device_info      │    │ refresh_token_id(FK)│
│ is_active       │    │ ip_address       │    │ status              │
│ is_customer     │    │ user_agent       │    │ expires_at          │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
         │                       │                        │
         │                       │                        │
         ▼                       ▼                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   audit_logs    │    │ rate_limit_logs  │    │   session_logs      │
├─────────────────┤    ├──────────────────┤    ├─────────────────────┤
│ id (PK)         │    │ id (PK)          │    │ id (PK)             │
│ user_id (FK)    │    │ identifier       │    │ user_id (FK)        │
│ action          │    │ action           │    │ action              │
│ resource        │    │ attempts         │    │ session_token       │
│ ip_address      │    │ blocked_until    │    │ ip_address          │
│ success         │    │ created_at       │    │ success             │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
```

## 👥 **RBAC (ROLE-BASED ACCESS CONTROL) LAYER**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│      roles      │    │   permissions    │    │   user_permissions  │
├─────────────────┤    ├──────────────────┤    ├─────────────────────┤
│ id (PK)         │    │ id (PK)          │    │ id (PK)             │
│ name            │    │ name             │    │ user_id (FK)        │
│ description     │    │ resource         │    │ permission_id (FK)  │
│ is_active       │    │ action           │    │ granted_by (FK)     │
└─────────────────┘    └──────────────────┘    │ expires_at          │
         │                       │             │ is_active           │
         │                       │             └─────────────────────┘
         │                       │                        │
         │                       │                        │
         ▼                       ▼                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│    user_roles   │    │ role_permissions │    │      users          │
├─────────────────┤    ├──────────────────┤    ├─────────────────────┤
│ user_id (FK)    │    │ role_id (FK)     │    │ id (PK)             │
│ role_id (FK)    │    │ permission_id(FK)│    │ username            │
└─────────────────┘    └──────────────────┘    │ email               │
                                               │ hashed_password     │
                                               │ is_active           │
                                               └─────────────────────┘
```

## 🏥 **BUSINESS LOGIC LAYER**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   appointments  │    │     bookings     │    │     customers       │
├─────────────────┤    ├──────────────────┤    ├─────────────────────┤
│ id (PK)         │    │ id (PK)          │    │ id (PK)             │
│ user_id (FK)    │    │ user_id (FK)     │    │ user_id (FK)        │
│ customer_id(FK) │    │ customer_id (FK) │    │ name                │
│ service_id      │    │ appointment_id(FK)│   │ contact_info        │
│ appointment_date│    │ booking_date     │    │ preferences         │
│ status          │    │ status           │    │ loyalty_points      │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
         │                       │                        │
         │                       │                        │
         ▼                       ▼                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│     products    │    │payment_transactions│  │   order_events      │
├─────────────────┤    ├──────────────────┤    ├─────────────────────┤
│ id (PK)         │    │ id (PK)          │    │ id (PK)             │
│ name            │    │ booking_id (FK)  │    │ order_id            │
│ description     │    │ customer_id (FK) │    │ event_type          │
│ price           │    │ amount           │    │ event_data          │
│ category        │    │ payment_method   │    │ created_at          │
│ is_active       │    │ status           │    └─────────────────────┘
└─────────────────┘    └──────────────────┘
         │
         ▼
┌─────────────────┐
│ inventory_logs  │
├─────────────────┤
│ id (PK)         │
│ product_id (FK) │
│ action          │
│ quantity        │
│ timestamp       │
└─────────────────┘
```

## 🎁 **REWARDS & MARKETING LAYER**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│     rewards     │    │      offers      │    │  advertisements     │
├─────────────────┤    ├──────────────────┤    ├─────────────────────┤
│ id (PK)         │    │ id (PK)          │    │ id (PK)             │
│ name            │    │ name             │    │ title               │
│ type            │    │ description      │    │ content             │
│ value           │    │ discount_percent │    │ target_audience     │
│ conditions      │    │ valid_from       │    │ is_active           │
│ is_active       │    │ valid_until      │    │ created_at          │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
         │                       │                        │
         │                       │                        │
         ▼                       ▼                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│    referrals    │    │   customer_offers│    │ customer_ads_viewed │
├─────────────────┤    ├──────────────────┤    ├─────────────────────┤
│ id (PK)         │    │ id (PK)          │    │ id (PK)             │
│ referrer_id(FK) │    │ customer_id (FK) │    │ customer_id (FK)    │
│ referred_id(FK) │    │ offer_id (FK)    │    │ ad_id (FK)          │
│ reward_points   │    │ used_at          │    │ viewed_at           │
│ status          │    │ status           │    │ clicked             │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
```

## 🔗 **CROSS-LAYER RELATIONSHIPS**

### **User-Centric Flow**
```
users (1) ←→ (many) appointments
users (1) ←→ (many) bookings  
users (1) ←→ (many) customers
users (1) ←→ (many) refresh_tokens
users (1) ←→ (many) audit_logs
```

### **Security Flow**
```
users (many) ←→ (many) roles (via user_roles)
roles (many) ←→ (many) permissions (via role_permissions)
users (1) ←→ (many) user_permissions
```

### **Business Flow**
```
customers (1) ←→ (many) appointments
customers (1) ←→ (many) bookings
bookings (1) ←→ (many) payment_transactions
products (1) ←→ (many) inventory_logs
```

## 📊 **Data Flow Patterns**

### **Authentication Flow**
```
1. User Login → users table
2. Create Token → refresh_tokens table  
3. Create Session → enhanced_user_sessions table
4. Log Event → audit_logs table
```

### **Authorization Flow**
```
1. Check User Roles → user_roles table
2. Check Role Permissions → role_permissions table
3. Check Direct Permissions → user_permissions table
4. Log Access → audit_logs table
```

### **Business Flow**
```
1. Customer Books → bookings table
2. Create Appointment → appointments table
3. Process Payment → payment_transactions table
4. Track Events → order_events table
5. Update Inventory → inventory_logs table
```

## 🎯 **Key Design Principles**

1. **Separation of Concerns**: Each layer handles specific functionality
2. **Security First**: Authentication and authorization are separate from business logic
3. **Audit Trail**: All important actions are logged for security and compliance
4. **Scalability**: Many-to-many relationships allow flexible permission management
5. **Data Integrity**: Foreign keys ensure referential integrity across all tables
