# 🔧 App Testing Guide - Fix Your APK Issues

## 🚨 Current Issues
- Registration not working
- Login not working
- Other functionality issues

## 🔍 How to Test Your App

### **Step 1: Install the APK**
1. **Transfer APK** to your Android phone
2. **Enable Unknown Sources** in Settings → Security
3. **Install the APK**
4. **Open "Oliva" app**

### **Step 2: Access Diagnostic Screen**
1. **Open the app**
2. **Look for red bug icon** (🔴) floating on screen
3. **Tap the red bug icon**
4. **This opens the diagnostic screen**

### **Step 3: Run Diagnostic Tests**
In the diagnostic screen, tap these buttons:

#### **🔗 Test Backend**
- Tests if your backend server is reachable
- Should show "Backend connected successfully"
- If it fails, your backend server is not running

#### **📱 Test OTP**
- Tests the OTP sending functionality
- Should show "OTP sent successfully"
- If it fails, there's an issue with OTP service

#### **🔑 Test Token Service**
- Tests local storage functionality
- Should show "Token service working"
- If it fails, there's an issue with app storage

## 📋 What Each Test Does

### **Backend Test**
- ✅ **Success**: Backend server is running and reachable
- ❌ **Failure**: Backend server is not running or not accessible

### **OTP Test**
- ✅ **Success**: OTP can be sent to phone number
- ❌ **Failure**: SMS service not configured or backend issue

### **Token Service Test**
- ✅ **Success**: App can save/retrieve data locally
- ❌ **Failure**: App storage permissions or configuration issue

## 🔧 Common Issues & Solutions

### **Issue 1: "Backend connection failed"**
**Solution:**
1. **Start your backend server**:
   ```bash
   cd MAD/BackendMobileAPP
   python -m uvicorn main:app --host 0.0.0.0 --port 8000
   ```
2. **Check if server is running** on `http://localhost:8000`
3. **Test again** in diagnostic screen

### **Issue 2: "OTP send failed"**
**Solution:**
1. **Check backend logs** for OTP errors
2. **Verify SMS configuration** in backend
3. **Use OTP from console** for testing

### **Issue 3: "Token service failed"**
**Solution:**
1. **Check app permissions** on phone
2. **Clear app data** and try again
3. **Reinstall the app**

## 📱 Manual Testing Steps

### **Test 1: Login Flow**
1. **Enter phone number**: `+919676052644`
2. **Click "Send OTP"**
3. **Check backend console** for OTP
4. **Enter OTP** in app
5. **Should login successfully**

### **Test 2: Registration Flow**
1. **Go to registration screen**
2. **Enter phone number**: `+919676052644`
3. **Enter password**
4. **Click "Send OTP"**
5. **Enter OTP** from console
6. **Complete registration**

### **Test 3: Video Call OTP**
1. **Login to app**
2. **Go to dashboard**
3. **Click "Join Video"** on consultation
4. **Enter OTP** from console
5. **Video call should open**

## 🎯 Expected Results

### **✅ Working Features:**
- App installs without errors
- Diagnostic screen opens
- Backend connection works
- OTP sending works
- Token service works
- Login with OTP works
- Video call OTP works

### **❌ Common Problems:**
- Backend server not running
- SMS service not configured
- Network connectivity issues
- App permissions denied

## 🔄 Quick Fixes

### **If Backend is Down:**
```bash
cd MAD/BackendMobileAPP
python -m uvicorn main:app --host 0.0.0.0 --port 8000
```

### **If OTP Not Working:**
- Use OTP from backend console
- Check SMS configuration in backend
- Test with different phone number

### **If App Crashes:**
- Clear app data
- Reinstall APK
- Check Android version (needs 5.0+)

## 📞 Support Steps

1. **Run diagnostic tests** first
2. **Note down error messages**
3. **Check backend server status**
4. **Test with different devices**
5. **Share error logs** for help

## 🎉 Success Indicators

✅ **App installs successfully**  
✅ **Diagnostic screen opens**  
✅ **Backend connection works**  
✅ **OTP sending works**  
✅ **Login flow works**  
✅ **Video call OTP works**  

---

**💡 Tip**: Use the diagnostic screen (red bug icon) to quickly identify what's working and what's not! 