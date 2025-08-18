@echo off
echo Fixing APK version compatibility...
echo.

echo Step 1: Getting dependencies...
flutter pub get

echo.
echo Step 2: Building compatible APK...
flutter build apk --debug --no-tree-shake-icons

echo.
echo Step 3: Copying to accessible location...
if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    copy "build\app\outputs\flutter-apk\app-debug.apk" "oliva-clinic-app-compatible.apk"
    echo ✅ Compatible APK created: oliva-clinic-app-compatible.apk
) else (
    echo ❌ APK build failed
)

echo.
echo Step 4: APK should now be compatible with most Android devices
echo.
pause 