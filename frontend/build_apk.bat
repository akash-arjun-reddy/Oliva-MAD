@echo off
echo 🚀 Starting APK build process...

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Build APK for release
echo 🔨 Building APK for release...
flutter build apk --release

REM Check if build was successful
if %ERRORLEVEL% EQU 0 (
    echo ✅ APK built successfully!
    echo 📱 APK location: build\app\outputs\flutter-apk\app-release.apk
    
    REM Copy APK to a more accessible location
    copy "build\app\outputs\flutter-apk\app-release.apk" "oliva-clinic-app.apk"
    echo 📋 APK copied to: oliva-clinic-app.apk
    
    REM Show APK size
    for %%A in (oliva-clinic-app.apk) do echo 📏 APK size: %%~zA bytes
) else (
    echo ❌ APK build failed!
    exit /b 1
)

echo 🎉 Build process completed!
pause 