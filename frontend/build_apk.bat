@echo off
echo Building Flutter APK...
echo.

echo Step 1: Cleaning project...
flutter clean

echo.
echo Step 2: Getting dependencies...
flutter pub get

echo.
echo Step 3: Building debug APK...
flutter build apk --debug

echo.
echo Step 4: Building release APK...
flutter build apk --release

echo.
echo APK files should be created in:
echo build/app/outputs/flutter-apk/
echo.
echo Debug APK: app-debug.apk
echo Release APK: app-release.apk
echo.
pause 