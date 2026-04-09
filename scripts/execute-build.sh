#!/bin/bash
# execute-build.sh - Manual build execution for BloodPulse
# Run this on a machine with Flutter SDK installed

set -e

echo "========================================"
echo "BloodPulse Manual Build & Deploy"
echo "========================================"

cd /shared/build/artifacts/bloodpulse

echo ""
echo "Step 1: Getting dependencies..."
flutter pub get

echo ""
echo "Step 2: Building APK..."
flutter build apk --release --build-number=101

echo ""
echo "Step 3: Verifying APK..."
APK="build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK" ]; then
    SIZE=$(stat -c%s "$APK" 2>/dev/null || stat -f%z "$APK" 2>/dev/null)
    echo "✅ APK built: $APK ($SIZE bytes)"
    
    # Copy to test-results
    mkdir -p test-results
    cp "$APK" test-results/app-release-final.apk
    
    echo "✅ APK copied to test-results/app-release-final.apk"
else
    echo "❌ APK build failed!"
    exit 1
fi

echo ""
echo "Step 4: Deploying to Appetize..."
if [ -n "$APPETIZE_API_TOKEN" ]; then
    ./scripts/deploy-appetize.sh test-results/app-release-final.apk
else
    echo "⚠️  APPETIZE_API_TOKEN not set. Deploy manually:"
    echo "   APPETIZE_API_TOKEN=your_token ./scripts/deploy-appetize.sh test-results/app-release-final.apk"
fi

echo ""
echo "========================================"
echo "Build & Deploy Complete!"
echo "========================================"
