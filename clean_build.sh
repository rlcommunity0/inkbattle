#!/bin/bash
# Script to free disk space before Flutter build
# Run this when you get "no space left on device" error
# Usage: ./clean_build.sh   (then run: flutter build apk --release)

set -e
echo "=== 1. Cleaning Flutter build cache ==="
flutter clean

echo ""
echo "=== 2. Cleaning Gradle cache (Android) ==="
cd android
./gradlew clean 2>/dev/null || true
cd ..

echo ""
echo "=== 3. Clearing Gradle global cache (frees significant space) ==="
rm -rf ~/.gradle/caches/transforms-* 2>/dev/null || true
rm -rf ~/.gradle/caches/build-cache-* 2>/dev/null || true

echo ""
echo "=== 4. Clearing Dart pub cache ==="
flutter pub cache clean

echo ""
echo "=== 5. Restoring dependencies ==="
flutter pub get

echo ""
echo "=== 6. Disk space after cleanup ==="
df -h .

echo ""
echo "=== 7. Building release APK ==="
flutter build apk --release

echo ""
echo "=== Build complete! APK is in build/app/outputs/flutter-apk/ ==="
