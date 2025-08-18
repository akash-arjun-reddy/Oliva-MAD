# 🔧 Fix "Unsupported Version" APK Issue

## 🚨 Problem
The APK shows "unsupported version" when trying to install on Android devices.

## ✅ Solutions

### **Solution 1: Use Debug APK (Recommended)**
The debug APK is more compatible with different Android versions.

**File**: `oliva-clinic-app.apk` (already created)
**Location**: `C:\MAD SQUARE\MAD\frontend\oliva-clinic-app.apk`

### **Solution 2: Build New Compatible APK**
Run the fix script:
```bash
.\fix_apk_version.bat
```

This will create: `oliva-clinic-app-compatible.apk`

### **Solution 3: Manual Installation Steps**

#### **For Recipients (Android Users)**:

1. **Enable Developer Options**:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"

2. **Enable Unknown Sources**:
   - Settings → Security → Unknown Sources
   - Enable "Allow installation from unknown sources"

3. **Install APK**:
   - Download the APK file
   - Open File Manager
   - Find the APK file
   - Tap to install
   - Follow prompts

### **Solution 4: Alternative Sharing Methods**

#### **Method A: Google Drive**
1. Upload APK to Google Drive
2. Right-click → "Get shareable link"
3. Share link with others

#### **Method B: WhatsApp**
1. Open WhatsApp
2. Select contact
3. Tap attachment (📎)
4. Choose "Document"
5. Select APK file
6. Send

#### **Method C: Email**
1. Open email client
2. Create new email
3. Attach APK file
4. Send to recipient

## 📱 Compatibility Info

**Supported Android Versions**:
- ✅ Android 5.0 (API 21) and higher
- ✅ Most modern Android devices
- ✅ Samsung, Xiaomi, OnePlus, etc.

**Minimum Requirements**:
- RAM: 2GB
- Storage: 100MB free space
- Internet: Required for backend connection

## 🔍 Troubleshooting

### **"App not installed"**
- Enable Unknown Sources
- Check if APK is corrupted
- Try downloading again

### **"Parse error"**
- APK might be corrupted
- Download fresh copy
- Check file size (should be ~51MB)

### **"Incompatible device"**
- Check Android version (needs 5.0+)
- Try on different device
- Use debug APK version

## 📋 Quick Test

1. **Install APK** on Android device
2. **Open "Oliva" app**
3. **Enter phone**: `+919676052644`
4. **Click "Send OTP"**
5. **Use OTP from backend console**
6. **Test video call feature**

## 🎯 Success Indicators

✅ App installs without errors  
✅ App opens successfully  
✅ Login screen appears  
✅ OTP verification works  
✅ Dashboard loads  
✅ Video call OTP works  

---

**💡 Tip**: The debug APK (`oliva-clinic-app.apk`) should work on most Android devices. If you still get "unsupported version", try the compatible version created by the fix script. 