# Developer Quick Reference Guide

## 🚀 **Quick Start**

### **Authentication Flow**
```python
# 1. User login
user = auth_service.login_user(email, password)

# 2. Create refresh token
tokens = security_service.create_refresh_token(
    user_id=user.id,
    device_info="iPhone 14",
    ip_address="192.168.1.1"
)

# 3. Return to client
return {
    "access_token": tokens["access_token"],
    "refresh_token": tokens["refresh_token"],
    "expires_in": tokens["expires_in"]
}
```

### **Authorization Check**
```python
# Check if user has permission
has_permission = rbac_service.check_permission(
    user_id=user.id,
    resource="appointment",
    action="create"
)

if not has_permission:
    raise HTTPException(status_code=403, detail="Insufficient permissions")
```

## 📋 **Table Quick Reference**

### **🔐 Authentication Tables**
| Table | Purpose | Key Fields | Relationships |
|-------|---------|------------|---------------|
| `users` | User accounts | `id`, `username`, `email` | Links to all user-related data |
| `refresh_tokens` | Long-lived tokens | `user_id`, `token_hash`, `expires_at` | Links to `users` |
| `enhanced_user_sessions` | Session management | `user_id`, `session_id`, `status` | Links to `users`, `refresh_tokens` |
| `audit_logs` | Security audit trail | `user_id`, `action`, `resource` | Links to `users` |
| `rate_limit_logs` | Rate limiting | `identifier`, `action`, `attempts` | No direct relationships |

### **👥 RBAC Tables**
| Table | Purpose | Key Fields | Relationships |
|-------|---------|------------|---------------|
| `roles` | System roles | `id`, `name`, `description` | Links to `users` via `user_roles` |
| `permissions` | System permissions | `id`, `resource`, `action` | Links to `roles` via `role_permissions` |
| `user_roles` | User-role mapping | `user_id`, `role_id` | Junction table |
| `role_permissions` | Role-permission mapping | `role_id`, `permission_id` | Junction table |
| `user_permissions` | Direct user permissions | `user_id`, `permission_id` | Links to `users`, `permissions` |

### **🏥 Business Tables**
| Table | Purpose | Key Fields | Relationships |
|-------|---------|------------|---------------|
| `appointments` | Medical appointments | `id`, `user_id`, `customer_id` | Links to `users`, `customers` |
| `bookings` | Service bookings | `id`, `user_id`, `customer_id` | Links to `users`, `customers` |
| `customers` | Customer profiles | `id`, `user_id`, `name` | Links to `users` |
| `products` | Product catalog | `id`, `name`, `price` | Links to `inventory_logs` |
| `payment_transactions` | Payment records | `id`, `booking_id`, `amount` | Links to `bookings` |

## 🔧 **Common Operations**

### **User Management**
```python
# Create user
user = User(
    username="john_doe",
    email="john@example.com",
    hashed_password=hashed_password,
    is_customer=True
)
db.add(user)
db.commit()

# Assign role
rbac_service.assign_role_to_user(
    user_id=user.id,
    role_id=role.id
)
```

### **Session Management**
```python
# Get user sessions
sessions = security_service.get_user_sessions(user_id=user.id)

# Revoke all sessions
revoked_count = security_service.revoke_all_user_sessions(user_id=user.id)
```

### **Audit Logging**
```python
# Log successful action
security_service.log_audit_event(
    user_id=user.id,
    action="appointment_created",
    resource="/appointments",
    ip_address="192.168.1.1",
    success=True
)

# Log failed action
security_service.log_audit_event(
    user_id=user.id,
    action="login_failed",
    resource="/auth/login",
    ip_address="192.168.1.1",
    success=False,
    error_message="Invalid credentials"
)
```

### **Permission Management**
```python
# Check permission
can_create = rbac_service.check_permission(
    user_id=user.id,
    resource="appointment",
    action="create"
)

# Grant direct permission
rbac_service.grant_permission_to_user(
    user_id=user.id,
    permission_id=permission.id,
    expires_at="2024-12-31"
)
```

## 🛡️ **Security Best Practices**

### **Token Management**
```python
# Always hash tokens before storing
token_hash = hashlib.sha256(token.encode()).hexdigest()

# Set appropriate expiration times
REFRESH_TOKEN_EXPIRE_DAYS = 30
ACCESS_TOKEN_EXPIRE_MINUTES = 15
```

### **Rate Limiting**
```python
# Check rate limit before processing
allowed = security_service.check_rate_limit(
    identifier="192.168.1.1",  # or user_id or email
    action="login",
    max_attempts=5,
    window_minutes=15
)

if not allowed:
    raise HTTPException(status_code=429, detail="Too many requests")
```

### **Audit Logging**
```python
# Log all security-relevant events
security_service.log_audit_event(
    user_id=user.id,
    action="permission_granted",
    resource="/rbac/permissions",
    metadata={"permission_name": "admin_access"}
)
```

## 📊 **Query Examples**

### **Get User with Roles and Permissions**
```python
user = db.query(User).filter(User.id == user_id).first()
user_roles = rbac_service.get_user_roles(user_id)
user_permissions = rbac_service.get_user_permissions(user_id)
```

### **Get User Sessions**
```python
sessions = security_service.get_user_sessions(user_id)
for session in sessions:
    print(f"Session: {session['session_id']}")
    print(f"Last Activity: {session['last_activity']}")
    print(f"Device: {session['device_info']}")
```

### **Get Audit Logs**
```python
logs = security_service.get_audit_logs(
    user_id=user_id,
    action="login",
    limit=50
)
```

## 🔍 **Troubleshooting**

### **Common Issues**

1. **Foreign Key Errors**
   - Ensure user exists before creating related records
   - Check data types match (Integer vs String)

2. **Permission Denied**
   - Check user roles: `rbac_service.get_user_roles(user_id)`
   - Check direct permissions: `rbac_service.get_user_permissions(user_id)`
   - Verify permission exists: `rbac_service.check_permission(user_id, resource, action)`

3. **Session Issues**
   - Check session status: `security_service.get_user_sessions(user_id)`
   - Verify token expiration: Check `refresh_tokens.expires_at`
   - Clean up expired sessions: `security_service.cleanup_expired_tokens()`

### **Debug Queries**
```python
# Check user authentication status
user = db.query(User).filter(User.id == user_id).first()
print(f"User active: {user.is_active}")
print(f"User locked: {user.is_locked}")

# Check rate limiting
rate_limits = db.query(RateLimitLog).filter(
    RateLimitLog.identifier == "192.168.1.1"
).all()

# Check audit trail
audit_logs = db.query(AuditLog).filter(
    AuditLog.user_id == user_id
).order_by(AuditLog.created_at.desc()).limit(10).all()
```

## 📈 **Performance Tips**

1. **Index Usage**: All foreign keys and frequently queried fields are indexed
2. **Query Optimization**: Use joins instead of multiple queries
3. **Caching**: Cache user permissions and roles for frequently accessed data
4. **Cleanup**: Regularly clean up expired tokens and old audit logs
5. **Pagination**: Use pagination for large result sets (audit logs, sessions)

## 🔄 **Migration Notes**

- All new security tables use Integer foreign keys to match existing `users.id`
- Legacy `user_sessions` table coexists with new `enhanced_user_sessions`
- RBAC system is additive - doesn't break existing role-based logic
- Audit logging is non-intrusive - doesn't affect existing functionality
