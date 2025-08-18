@echo off
echo 🚀 Starting Oliva Clinic Backend Deployment...

REM Check if flyctl is installed
flyctl version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ flyctl is not installed. Please install it first:
    echo iwr https://fly.io/install.ps1 -useb ^| iex
    pause
    exit /b 1
)

REM Check if user is logged in
flyctl auth whoami >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Not logged in to Fly.io. Please run: flyctl auth login
    pause
    exit /b 1
)

REM Check if app exists
flyctl apps list | findstr "oliva-clinic-backend" >nul
if %errorlevel% neq 0 (
    echo 📱 Creating new Fly.io app...
    flyctl launch --name oliva-clinic-backend --region bom --no-deploy
) else (
    echo 📱 App already exists, proceeding with deployment...
)

REM Set environment variables
echo 🔧 Setting environment variables...
set /p DATABASE_URL="Please enter your Neon database URL: "
set /p SECRET_KEY="Please enter your secret key: "

REM Set secrets
flyctl secrets set DATABASE_URL="%DATABASE_URL%"
flyctl secrets set SECRET_KEY="%SECRET_KEY%"
flyctl secrets set ALGORITHM="HS256"
flyctl secrets set ACCESS_TOKEN_EXPIRE_MINUTES="30"

echo ✅ Environment variables set successfully!

REM Deploy the app
echo 🚀 Deploying to Fly.io...
flyctl deploy

REM Check deployment status
echo 📊 Checking deployment status...
flyctl status

echo 🎉 Deployment completed!
echo Your app is available at: https://oliva-clinic-backend.fly.dev
echo Health check: https://oliva-clinic-backend.fly.dev/health
echo API docs: https://oliva-clinic-backend.fly.dev/docs

REM Open the app in browser
echo 🌐 Opening app in browser...
flyctl open

pause 