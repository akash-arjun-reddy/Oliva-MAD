# 🛠️ Complete Setup Guide for Oliva Clinic App

This guide will walk you through setting up automatic deployment to Render and APK generation.

## 📋 What You'll Get

✅ **Automatic Backend Deployment** - Deploys to Render on every push  
✅ **Automatic Frontend Deployment** - Deploys Flutter web to Render  
✅ **Automatic APK Generation** - Creates APK on every push  
✅ **GitHub Releases** - Automatic APK distribution  
✅ **CI/CD Pipeline** - Complete automation  

## 🚀 Step-by-Step Setup

### Step 1: Prepare Your Repository

1. **Fork this repository** to your GitHub account
2. **Clone locally:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/MAD.git
   cd MAD
   ```

### Step 2: Set Up Render Backend

1. **Go to [Render Dashboard](https://dashboard.render.com)**
2. **Create New Web Service:**
   - Click "New +" → "Web Service"
   - Connect your GitHub repository
   - Select `BackendMobileAPP` as the root directory
   - Name: `oliva-clinic-backend`

3. **Configure Build Settings:**
   ```
   Runtime: Python 3
   Build Command: pip install -r requirements.txt
   Start Command: uvicorn main:app --host 0.0.0.0 --port $PORT
   ```

4. **Add Environment Variables:**
   ```
   DATABASE_URL=postgresql://user:password@host:port/database
   SECRET_KEY=your-secret-key-here
   GOOGLE_CLIENT_ID=your-google-client-id
   GOOGLE_CLIENT_SECRET=your-google-client-secret
   AZURE_MAIL_PASSWORD=your-azure-password
   ZENOTI_API_KEY=your-zenoti-api-key
   SENDGRID_API_KEY=your-sendgrid-api-key
   ```

5. **Create Database:**
   - In Render Dashboard, go to "New +" → "PostgreSQL"
   - Name: `oliva-clinic-db`
   - Copy the connection string to `DATABASE_URL`

### Step 3: Set Up Render Frontend

1. **Create Static Site:**
   - Click "New +" → "Static Site"
   - Connect your GitHub repository
   - Select `frontend` as the root directory
   - Name: `oliva-clinic-frontend`

2. **Configure Build Settings:**
   ```
   Build Command: flutter build web --release
   Publish Directory: build/web
   ```

### Step 4: Configure GitHub Secrets

1. **Get Render API Token:**
   - Go to Render Dashboard → Account Settings → API Keys
   - Create new API key
   - Copy the token

2. **Get Service IDs:**
   - Go to your backend service → Settings → General
   - Copy the Service ID
   - Do the same for frontend service

3. **Add GitHub Secrets:**
   - Go to your GitHub repository → Settings → Secrets and variables → Actions
   - Add these secrets:
     ```
     RENDER_TOKEN=your-render-api-token
     RENDER_BACKEND_SERVICE_ID=your-backend-service-id
     RENDER_FRONTEND_SERVICE_ID=your-frontend-service-id
     ```

### Step 5: Test Local Development

1. **Test Backend:**
   ```bash
   cd BackendMobileAPP
   pip install -r requirements.txt
   python main.py
   # Visit http://localhost:8000/test
   ```

2. **Test Frontend:**
   ```bash
   cd frontend
   flutter pub get
   flutter run
   ```

3. **Test APK Generation:**
   ```bash
   cd frontend
   # On Windows:
   build_apk.bat
   # On Mac/Linux:
   ./build_apk.sh
   ```

### Step 6: Push and Deploy

1. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Initial deployment setup"
   git push origin main
   ```

2. **Monitor Deployment:**
   - Check GitHub Actions tab for build status
   - Check Render Dashboard for deployment status
   - Download APK from GitHub Releases

## 🔄 Automatic Workflow

Once set up, here's what happens automatically:

1. **You make changes** → Push to GitHub
2. **GitHub Actions triggers** → Runs tests and builds
3. **Backend deploys** → To Render automatically
4. **Frontend deploys** → To Render automatically  
5. **APK generates** → Uploaded to GitHub Releases
6. **Users get updates** → Download latest APK

## 📱 APK Distribution

### Automatic (Recommended)
- APKs are generated on every push to main branch
- Available in GitHub Releases
- Users can download directly from GitHub

### Manual Generation
```bash
# Windows
cd frontend
build_apk.bat

# Mac/Linux
cd frontend
./build_apk.sh
```

## 🔧 Environment Configuration

### Backend Environment Variables
```env
# Database
DATABASE_URL=postgresql://user:password@host:port/database

# Security
SECRET_KEY=your-secret-key-here

# OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Email
AZURE_MAIL_PASSWORD=your-azure-password
SENDGRID_API_KEY=your-sendgrid-api-key

# External APIs
ZENOTI_API_KEY=your-zenoti-api-key
```

### Frontend Configuration
The app automatically detects:
- **Development**: Uses local backend (`http://localhost:8000`)
- **Production**: Uses Render backend (`https://your-backend.onrender.com`)

## 🧪 Testing Your Setup

### 1. Test Backend API
```bash
curl https://your-backend.onrender.com/test
# Should return: {"message":"Backend is working!","status":"success"}
```

### 2. Test Frontend
- Visit your frontend URL
- Should load the Flutter web app
- Test login/registration functionality

### 3. Test APK
- Download APK from GitHub Releases
- Install on Android device
- Test all functionality

## 📊 Monitoring

### Render Dashboard
- Monitor backend performance
- View logs and errors
- Check deployment status

### GitHub Actions
- Monitor build status
- View test results
- Download APK artifacts

### GitHub Releases
- View all APK versions
- Download specific versions
- Read release notes

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

## 🎉 Success!

Once everything is set up:

✅ **Backend**: Running on Render  
✅ **Frontend**: Running on Render  
✅ **APK**: Automatically generated  
✅ **Deployment**: Fully automated  
✅ **Updates**: Push to deploy  

Your app is now ready for production! 🚀

---

**Need help?** Check the `DEPLOYMENT.md` file for detailed troubleshooting. 