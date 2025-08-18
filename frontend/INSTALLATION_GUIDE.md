# Oliva Clinic App - Installation Guide

## 📱 APK File
**File Name**: `oliva-clinic-app.apk`  
**Size**: 51MB  
**Version**: 1.0.0  
**Build Type**: Debug

## 🚀 Installation Instructions

### For Android Phones:

1. **Enable Unknown Sources**:
   - Go to Settings → Security → Unknown Sources
   - Enable "Allow installation from unknown sources"

2. **Transfer APK to Phone**:
   - Copy `oliva-clinic-app.apk` to your Android phone
   - You can use USB cable, email, or cloud storage

3. **Install APK**:
   - Open File Manager on your phone
   - Navigate to the APK file
   - Tap on `oliva-clinic-app.apk`
   - Tap "Install"
   - Follow the installation prompts

4. **Launch App**:
   - Find "Oliva" app in your app drawer
   - Tap to open

## 🔧 App Features

### ✅ Working Features:
- **Phone Number Login**: Enter your phone number (+919676052644)
- **OTP Verification**: Use OTP from backend console
- **Dashboard**: View upcoming consultations
- **Video Call OTP**: Join video consultations with OTP
- **Navigation**: Bottom navigation bar
- **UI**: Modern, responsive design

### 📋 How to Use:

1. **Login**:
   - Enter phone number: `+919676052644`
   - Click "Send OTP"
   - Check backend console for OTP code
   - Enter OTP in app

2. **Test Video Call**:
   - Navigate to dashboard
   - Click "Join Video" on consultation card
   - Enter OTP from console
   - Video call will open

## 🔗 Backend Connection

**Important**: The app connects to your local backend server. Make sure:
- Backend server is running on `localhost:8000`
- Or update the backend URL in the app configuration

## 📞 Support

If you encounter issues:
1. Check backend server is running
2. Verify phone number format (+919676052644)
3. Use OTP from backend console
4. Ensure internet connection

## 🔄 Updates

To update the app:
1. Build new APK: `flutter build apk --debug`
2. Install new APK over existing app
3. App will be updated automatically

## 📱 System Requirements

- **Android Version**: 5.0 (API 21) or higher
- **RAM**: 2GB minimum
- **Storage**: 100MB free space
- **Internet**: Required for backend connection

## 🎯 Testing Checklist

- [ ] App installs successfully
- [ ] Phone number login works
- [ ] OTP verification works
- [ ] Dashboard loads
- [ ] Video call OTP works
- [ ] Navigation works
- [ ] UI displays correctly

## 📁 File Locations

- **APK**: `oliva-clinic-app.apk` (in frontend directory)
- **Backend**: `MAD/BackendMobileAPP/`
- **Source Code**: `MAD/frontend/`

## 🚨 Troubleshooting

### "App not installed"
- Enable Unknown Sources in Settings
- Check if APK file is corrupted
- Try downloading again

### "Can't connect to backend"
- Ensure backend server is running
- Check internet connection
- Verify backend URL in app

### "OTP not working"
- Use OTP from backend console
- Check phone number format
- Ensure OTP is not expired (10 minutes)

---

**🎉 Enjoy using the Oliva Clinic App!** 