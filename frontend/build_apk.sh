#!/bin/bash

# Build APK script for Oliva Clinic App
echo "🚀 Starting APK build process..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build APK for release
echo "🔨 Building APK for release..."
flutter build apk --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ APK built successfully!"
    echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
    
    # Copy APK to a more accessible location
    cp build/app/outputs/flutter-apk/app-release.apk ./oliva-clinic-app.apk
    echo "📋 APK copied to: ./oliva-clinic-app.apk"
    
    # Show APK size
    APK_SIZE=$(du -h ./oliva-clinic-app.apk | cut -f1)
    echo "📏 APK size: $APK_SIZE"
else
    echo "❌ APK build failed!"
    exit 1
fi

echo "🎉 Build process completed!" 