# Database Schema Overview

## 📊 Table Organization by Functionality

### 🔐 **AUTHENTICATION & SECURITY TABLES**

#### **Core Authentication**
- **`users`** - Main user accounts and profiles
  - Stores user credentials, personal info, contact details
  - Primary key: `id` (Integer)
  - Key fields: `username`, `email`, `hashed_password`, `is_active`, `is_customer`

#### **Token Management**
- **`refresh_tokens`** - Long-lived refresh tokens for authentication
  - Links to users via `user_id`
  - Stores hashed tokens for security
  - Tracks device info, IP address, expiration

- **`user_sessions`** - Basic session management
  - Legacy session tracking
  - Links to users via `user_id`

- **`enhanced_user_sessions`** - Advanced session management
  - Enhanced session tracking with status management
  - Links to refresh tokens and users
  - Tracks device fingerprinting, activity

#### **Security Monitoring**
- **`audit_logs`** - Security audit trail
  - Records all security-relevant events
  - Tracks user actions, login attempts, permission changes
  - Stores IP addresses, user agents, success/failure status

- **`rate_limit_logs`** - Rate limiting enforcement
  - Prevents brute force attacks
  - Tracks attempts by IP/user/action
  - Implements blocking mechanisms

- **`session_logs`** - Session activity tracking
  - Logs session events (login, logout, token refresh)
  - Links to user sessions

---

### 👥 **ROLE-BASED ACCESS CONTROL (RBAC) TABLES**

#### **Core RBAC**
- **`roles`** - User roles and permissions
  - Defines system roles (admin, manager, staff, customer)
  - Contains role descriptions and status

- **`permissions`** - System permissions
  - Defines what actions can be performed on resources
  - Format: `resource:action` (e.g., "user:read", "appointment:create")

#### **RBAC Relationships**
- **`user_roles`** - Many-to-many relationship between users and roles
  - Links users to their assigned roles

- **`role_permissions`** - Many-to-many relationship between roles and permissions
  - Links roles to their assigned permissions

- **`user_permissions`** - Direct user permissions (bypasses roles)
  - Allows granting specific permissions directly to users
  - Supports temporary permissions with expiration

---

### 🏥 **BUSINESS LOGIC TABLES**

#### **Appointment Management**
- **`appointments`** - Medical appointments
  - Links patients to doctors and services
  - Tracks appointment status, dates, notes

#### **Booking System**
- **`bookings`** - Service bookings
  - Customer service reservations
  - Links to appointments and customers

#### **Customer Management**
- **`customers`** - Customer profiles
  - Extended customer information
  - Links to users and appointments

#### **Product & Inventory**
- **`products`** - Product catalog
  - Medical products, services, treatments
  - Pricing, availability, descriptions

- **`inventory_logs`** - Inventory tracking
  - Product stock movements
  - Purchase, sale, adjustment records

#### **Payment System**
- **`payment_transactions`** - Payment records
  - Financial transactions
  - Links to bookings, customers, payment methods

- **`order_events`** - Order lifecycle tracking
  - Order status changes and events
  - Audit trail for order processing

---

### 🎁 **REWARDS & LOYALTY TABLES**

#### **Rewards System**
- **`rewards`** - Reward definitions
  - Points, discounts, offers
  - Rules and conditions

- **`offers`** - Special offers and promotions
  - Time-limited deals
  - Customer targeting

- **`advertisements`** - Marketing content
  - Promotional materials
  - Customer engagement

#### **Referral System**
- **`referrals`** - Customer referral tracking
  - Referral relationships
  - Reward distribution

---

## 🔗 **Key Relationships**

### **User-Centric Relationships**
```
users (1) ←→ (many) refresh_tokens
users (1) ←→ (many) user_sessions
users (1) ←→ (many) enhanced_user_sessions
users (1) ←→ (many) audit_logs
users (1) ←→ (many) session_logs
users (many) ←→ (many) roles (via user_roles)
users (1) ←→ (many) user_permissions
```

### **RBAC Relationships**
```
roles (many) ←→ (many) permissions (via role_permissions)
users (many) ←→ (many) roles (via user_roles)
```

### **Business Relationships**
```
users (1) ←→ (many) appointments
users (1) ←→ (many) bookings
users (1) ←→ (many) customers
customers (1) ←→ (many) appointments
customers (1) ←→ (many) bookings
bookings (1) ←→ (many) payment_transactions
```

---

## 📋 **Table Summary by Function**

| Category | Tables | Purpose |
|----------|--------|---------|
| **Authentication** | `users`, `refresh_tokens`, `user_sessions`, `enhanced_user_sessions` | User identity and session management |
| **Security** | `audit_logs`, `rate_limit_logs`, `session_logs` | Security monitoring and enforcement |
| **RBAC** | `roles`, `permissions`, `user_roles`, `role_permissions`, `user_permissions` | Access control and authorization |
| **Business** | `appointments`, `bookings`, `customers`, `products`, `inventory_logs` | Core business operations |
| **Financial** | `payment_transactions`, `order_events` | Payment and order processing |
| **Marketing** | `rewards`, `offers`, `advertisements`, `referrals` | Customer engagement and loyalty |

---

## 🚀 **Usage Patterns**

### **Authentication Flow**
1. User registers/logs in → `users` table
2. System creates refresh token → `refresh_tokens` table
3. System creates session → `enhanced_user_sessions` table
4. System logs event → `audit_logs` table

### **Authorization Flow**
1. User requests resource → Check `user_roles` and `role_permissions`
2. If no role permission → Check `user_permissions`
3. Log access attempt → `audit_logs` table

### **Business Flow**
1. Customer books appointment → `bookings` table
2. System creates appointment → `appointments` table
3. Payment processed → `payment_transactions` table
4. Order events tracked → `order_events` table

---

## 🔧 **Maintenance Considerations**

### **Security Tables**
- `audit_logs` and `rate_limit_logs` can grow large → Implement archiving
- `refresh_tokens` and sessions should be cleaned up regularly
- Monitor `rate_limit_logs` for attack patterns

### **RBAC Tables**
- `user_roles` and `role_permissions` are many-to-many → Optimize queries
- `user_permissions` should be reviewed regularly for expired permissions

### **Business Tables**
- `appointments` and `bookings` are core business data → Regular backups
- `payment_transactions` contains sensitive data → Encrypt and secure
- `inventory_logs` can grow large → Implement data retention policies
