# 🔐 Session Management System Guide

## 📋 Overview

Your app now has a comprehensive session management system that tracks every login, logout, and session activity. This ensures users stay logged in across app restarts and provides detailed session analytics.

## 🎯 Key Features

### ✅ **Automatic Session Tracking**
- **Every login/logout** is logged with timestamp, IP, device info
- **Session activity** is tracked and updated automatically
- **Token expiration** is handled gracefully
- **Multiple device sessions** are supported

### ✅ **Persistent Login**
- **JWT tokens stored** in SharedPreferences (survives app restarts)
- **Auto-refresh** every 25 minutes (before 30-minute expiry)
- **Session validation** on app startup
- **Automatic logout** when session expires

### ✅ **Session Analytics**
- **View all active sessions** for a user
- **Session logs** with detailed activity history
- **Device tracking** (IP, user agent, device info)
- **Login/logout timestamps**

## 🔧 How It Works

### **1. Login Flow**
```
User Signs In → JWT Token Generated → Session Created → Token Stored Locally → Auto-refresh Timer Started
```

### **2. Session Persistence**
```
App Restart → Check Local Token → Validate with Backend → Resume Session or Redirect to Login
```

### **3. Auto-refresh**
```
Every 25 minutes → Call /sessions/refresh → Update Last Activity → Continue Session
```

### **4. Logout Flow**
```
User Logs Out → Session Deactivated → Token Cleared → Timer Stopped → Redirect to Login
```

## 📊 Database Tables

### **user_sessions**
- `id`: Primary key
- `user_id`: Reference to users table
- `session_token`: JWT token
- `device_info`: Device description
- `ip_address`: User's IP address
- `user_agent`: Browser/app info
- `is_active`: Session status
- `created_at`: Session creation time
- `last_activity`: Last activity time
- `expires_at`: Token expiration time

### **session_logs**
- `id`: Primary key
- `user_id`: Reference to users table
- `action`: login, logout, token_refresh, session_expired
- `session_token`: Associated token
- `ip_address`: User's IP address
- `user_agent`: Browser/app info
- `success`: Action success status
- `error_message`: Error details if any
- `created_at`: Log timestamp

## 🚀 API Endpoints

### **Session Management**
- `GET /sessions/status` - Get current session status
- `GET /sessions/my-sessions` - Get all user sessions
- `GET /sessions/my-session-logs` - Get session activity logs
- `POST /sessions/refresh` - Refresh session activity
- `POST /sessions/logout` - Logout current session
- `POST /sessions/logout-all` - Logout from all devices

## 💻 Frontend Integration

### **Initialize Session Monitoring**
```dart
// In your main.dart or app initialization
await SessionService.initializeSessionMonitoring();
```

### **Check Session Status**
```dart
final shouldStayLoggedIn = await SessionService.shouldStayLoggedIn();
if (shouldStayLoggedIn) {
  // Navigate to main app
} else {
  // Navigate to login
}
```

### **Logout**
```dart
await SessionService.logout(); // Current session only
await SessionService.logoutAllDevices(); // All devices
```

### **Get Session Info**
```dart
final sessionStatus = await SessionService.getSessionStatus();
final userSessions = await SessionService.getUserSessions();
final sessionLogs = await SessionService.getSessionLogs();
```

## 🔄 Auto-refresh Configuration

### **Current Settings**
- **Token Expiry**: 30 minutes
- **Refresh Interval**: 25 minutes (5 minutes before expiry)
- **Storage**: SharedPreferences (persistent)

### **Customize Settings**
```dart
// In session_service.dart
static const int _refreshIntervalMinutes = 25; // Change this value
```

```python
# In settings.py
ACCESS_TOKEN_EXPIRE_MINUTES: int = 30  # Change this value
```

## 📱 User Experience

### **What Users See**
1. **Login once** - Stay logged in until logout
2. **App restarts** - Automatically logged in
3. **Multiple devices** - Can use app on phone, tablet, web
4. **Session management** - View and manage active sessions
5. **Security** - Automatic logout on inactivity

### **What You Track**
- ✅ **Every login** with timestamp and device
- ✅ **Every logout** with reason
- ✅ **Session activity** and refresh attempts
- ✅ **Failed authentication** attempts
- ✅ **Device information** and IP addresses
- ✅ **Session duration** and expiration

## 🛡️ Security Features

### **Token Security**
- **JWT tokens** with 30-minute expiry
- **Automatic refresh** before expiration
- **Secure storage** in SharedPreferences
- **Server-side validation** on every request

### **Session Security**
- **IP tracking** for suspicious activity
- **Device tracking** for session management
- **Automatic cleanup** of expired sessions
- **Force logout** from all devices option

## 🔍 Monitoring & Analytics

### **Session Analytics**
```sql
-- Get user login frequency
SELECT user_id, COUNT(*) as login_count, 
       DATE(created_at) as login_date
FROM session_logs 
WHERE action = 'login' 
GROUP BY user_id, DATE(created_at);

-- Get active sessions by device
SELECT device_info, COUNT(*) as active_sessions
FROM user_sessions 
WHERE is_active = true 
GROUP BY device_info;

-- Get session duration
SELECT user_id, 
       AVG(EXTRACT(EPOCH FROM (last_activity - created_at))/3600) as avg_hours
FROM user_sessions 
WHERE is_active = false 
GROUP BY user_id;
```

### **Security Monitoring**
```sql
-- Failed login attempts
SELECT user_id, COUNT(*) as failed_attempts
FROM session_logs 
WHERE action = 'login' AND success = false
GROUP BY user_id;

-- Suspicious IP activity
SELECT ip_address, COUNT(*) as login_count
FROM session_logs 
WHERE action = 'login' 
GROUP BY ip_address 
HAVING COUNT(*) > 10;
```

## 🚀 Next Steps

### **Immediate Benefits**
- ✅ **No more repeated logins** after app restarts
- ✅ **Complete session tracking** for analytics
- ✅ **Multi-device support** with session management
- ✅ **Automatic session refresh** for seamless UX

### **Future Enhancements**
- 🔄 **Push notifications** for suspicious login attempts
- 🔄 **Session timeout** based on user activity
- 🔄 **Geographic session tracking** for security
- 🔄 **Session analytics dashboard** for insights

## 🎉 Summary

Your app now has enterprise-level session management:

1. **Users stay logged in** across app restarts
2. **Every session is tracked** for security and analytics
3. **Automatic token refresh** ensures seamless experience
4. **Multi-device support** with session management
5. **Complete audit trail** of all authentication events

**No more repeated signups after app restarts!** 🎯
