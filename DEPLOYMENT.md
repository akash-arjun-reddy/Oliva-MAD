# 🚀 Oliva Clinic App Deployment Guide

This guide explains how to deploy the Oliva Clinic backend and frontend to Render, and how to generate APKs automatically.

## 📋 Prerequisites

1. **GitHub Account** - For version control and CI/CD
2. **Render Account** - For hosting backend and frontend
3. **Flutter SDK** - For building APKs locally
4. **PostgreSQL Database** - For backend data storage

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Backend API   │    │   PostgreSQL    │
│   (Mobile/Web)  │◄──►│   (FastAPI)     │◄──►│   Database      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Quick Deployment Steps

### 1. Backend Deployment (Render)

1. **Fork/Clone this repository**
2. **Connect to Render:**
   - Go to [Render Dashboard](https://dashboard.render.com)
   - Click "New +" → "Web Service"
   - Connect your GitHub repository
   - Select the `BackendMobileAPP` directory

3. **Configure Environment Variables:**
   ```
   DATABASE_URL=postgresql://user:password@host:port/database
   SECRET_KEY=your-secret-key-here
   GOOGLE_CLIENT_ID=your-google-client-id
   GOOGLE_CLIENT_SECRET=your-google-client-secret
   AZURE_MAIL_PASSWORD=your-azure-password
   ZENOTI_API_KEY=your-zenoti-api-key
   SENDGRID_API_KEY=your-sendgrid-api-key
   ```

4. **Deploy:**
   - Render will automatically deploy when you push to main branch
   - Your backend will be available at: `https://your-app-name.onrender.com`

### 2. Frontend Deployment (Render)

1. **Create Static Site on Render:**
   - Go to Render Dashboard
   - Click "New +" → "Static Site"
   - Connect your GitHub repository
   - Select the `frontend` directory

2. **Configure Build Settings:**
   ```
   Build Command: flutter build web --release
   Publish Directory: build/web
   ```

3. **Deploy:**
   - Render will automatically build and deploy your Flutter web app
   - Your frontend will be available at: `https://your-frontend-name.onrender.com`

### 3. Automatic APK Generation

The GitHub Actions workflow will automatically:
- ✅ Build APK on every push to main branch
- ✅ Upload APK as GitHub artifact
- ✅ Create GitHub release with APK download
- ✅ Deploy backend and frontend to Render

## 🔧 Local Development

### Backend (Local)
```bash
cd BackendMobileAPP
pip install -r requirements.txt
python main.py
# Backend runs at http://localhost:8000
```

### Frontend (Local)
```bash
cd frontend
flutter pub get
flutter run
# App runs on your device/emulator
```

### APK Generation (Local)
```bash
cd frontend
chmod +x build_apk.sh
./build_apk.sh
# APK will be created at: ./oliva-clinic-app.apk
```

## 🔄 Automatic Deployment Flow

1. **Make Changes** → Push to GitHub
2. **GitHub Actions** → Automatically triggers
3. **Backend** → Deploys to Render
4. **Frontend** → Deploys to Render  
5. **APK** → Generated and uploaded to GitHub releases

## 📱 APK Distribution

### Automatic (Recommended)
- APKs are automatically generated on every main branch push
- Download from GitHub Releases page
- Latest version always available

### Manual
```bash
# Generate APK locally
cd frontend
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

## 🔐 Environment Variables

### Backend (Required)
```env
DATABASE_URL=postgresql://user:password@host:port/database
SECRET_KEY=your-secret-key-here
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
AZURE_MAIL_PASSWORD=your-azure-password
ZENOTI_API_KEY=your-zenoti-api-key
SENDGRID_API_KEY=your-sendgrid-api-key
```

### Frontend (Optional)
```env
FLUTTER_VERSION=3.24.0
```

## 🧪 Testing

### Backend Tests
```bash
cd BackendMobileAPP
python -m pytest tests/ -v
```

### Frontend Tests
```bash
cd frontend
flutter test
```

## 📊 Monitoring

### Render Dashboard
- Monitor backend performance
- View logs and errors
- Check deployment status

### GitHub Actions
- Monitor build status
- View test results
- Download APK artifacts

## 🔧 Troubleshooting

### Backend Issues
1. Check Render logs for errors
2. Verify environment variables
3. Test database connection
4. Check API endpoints at `/docs`

### Frontend Issues
1. Check Flutter build logs
2. Verify API endpoint configuration
3. Test on different devices
4. Check browser console for errors

### APK Issues
1. Check GitHub Actions logs
2. Verify Flutter version compatibility
3. Test APK on different Android versions
4. Check signing configuration

## 📞 Support

For issues or questions:
1. Check GitHub Issues
2. Review Render documentation
3. Check Flutter documentation
4. Contact development team

---

**🎉 Your app is now ready for production deployment!** 