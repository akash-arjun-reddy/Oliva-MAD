# 🔐 Google OAuth Setup Guide for Mobile

## 📱 **Current Status**
- ✅ **Web**: Configured but needs origins added to Google Cloud Console
- ❌ **Android**: Not configured - needs SHA-1 and google-services.json
- ❌ **iOS**: Not configured - needs Bundle ID and GoogleService-Info.plist

## 🤖 **Android Setup**

### **Step 1: Generate SHA-1 Fingerprint**

**Option A: If you have an existing keystore**
```bash
keytool -list -v -keystore "C:\Users\[YourUsername]\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Option B: Create new debug keystore and get SHA-1**
```bash
# Create debug keystore
keytool -genkey -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android -keyalg RSA -validity 10000 -dname "CN=Android Debug,O=Android,C=US"

# Get SHA-1 fingerprint
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### **Step 2: Add to Google Cloud Console**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services** → **Credentials**
3. Find your OAuth 2.0 Client ID: `601952184258-2e48qr0anivb3nm8dvil7jhiarg10j2d.apps.googleusercontent.com`
4. Click **Edit**
5. In **Android** section, add:
   - **Package name**: `com.example.frontend`
   - **SHA-1 certificate fingerprint**: (paste the SHA-1 from step 1)

### **Step 3: Download google-services.json**
1. In Google Cloud Console, go to **Project Settings**
2. Click **Your apps** → **Add app** → **Android**
3. Enter package name: `com.example.frontend`
4. Download `google-services.json`
5. Place it in: `frontend/android/app/google-services.json`

### **Step 4: Update Android Build Configuration**
The `google-services.json` file will be automatically detected by the Google Services plugin.

## 🍎 **iOS Setup**

### **Step 1: Bundle ID Configuration**
Your current bundle ID is: `com.example.frontend`

### **Step 2: Add to Google Cloud Console**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services** → **Credentials**
3. Find your OAuth 2.0 Client ID
4. Click **Edit**
5. In **iOS** section, add:
   - **Bundle ID**: `com.example.frontend`

### **Step 3: Download GoogleService-Info.plist**
1. In Google Cloud Console, go to **Project Settings**
2. Click **Your apps** → **Add app** → **iOS**
3. Enter bundle ID: `com.example.frontend`
4. Download `GoogleService-Info.plist`
5. Place it in: `frontend/ios/Runner/GoogleService-Info.plist`

### **Step 4: iOS Configuration (Already Done)**
The `Info.plist` has been updated with the Google Sign-In URL scheme.

## 🌐 **Web Setup (Complete First)**

### **Add These Origins to Google Cloud Console:**
**Authorized JavaScript origins:**
```
http://localhost:3000
http://localhost:8000
http://127.0.0.1:3000
http://127.0.0.1:8000
http://localhost:8080
http://127.0.0.1:8080
http://localhost:54112
http://127.0.0.1:54112
```

**Authorized redirect URIs:**
```
http://localhost:3000/
http://localhost:8000/
http://127.0.0.1:3000/
http://127.0.0.1:8000/
http://localhost:8080/
http://127.0.0.1:8080/
http://localhost:54112/
http://127.0.0.1:54112/
```

## 🚀 **Testing Order**

1. **First**: Fix web OAuth (add origins to Google Cloud Console)
2. **Second**: Test web OAuth in Flutter web app
3. **Third**: Set up Android (SHA-1 + google-services.json)
4. **Fourth**: Set up iOS (Bundle ID + GoogleService-Info.plist)
5. **Fifth**: Test on mobile devices

## 📋 **Checklist**

### **Web**
- [ ] Added origins to Google Cloud Console
- [ ] Tested Google Sign-In in web app

### **Android**
- [ ] Generated SHA-1 fingerprint
- [ ] Added SHA-1 to Google Cloud Console
- [ ] Downloaded google-services.json
- [ ] Placed google-services.json in android/app/
- [ ] Tested on Android device/emulator

### **iOS**
- [ ] Added Bundle ID to Google Cloud Console
- [ ] Downloaded GoogleService-Info.plist
- [ ] Placed GoogleService-Info.plist in ios/Runner/
- [ ] Tested on iOS device/simulator

## 🔧 **Troubleshooting**

### **Common Issues:**
1. **SHA-1 not found**: Create debug keystore first
2. **Bundle ID mismatch**: Ensure it matches in all places
3. **File not found**: Check file paths carefully
4. **OAuth errors**: Wait 2-3 minutes after Google Cloud Console changes

### **Verification Commands:**
```bash
# Check if google-services.json exists
ls frontend/android/app/google-services.json

# Check if GoogleService-Info.plist exists
ls frontend/ios/Runner/GoogleService-Info.plist

# Test web OAuth
flutter run -d chrome
```

## 🎯 **Next Steps**

1. **Start with web**: Add origins to Google Cloud Console
2. **Test web**: Verify Google Sign-In works in browser
3. **Then mobile**: Follow Android and iOS setup steps
4. **Test mobile**: Verify Google Sign-In works on devices

**Priority**: Fix web first, then mobile! 🚀
