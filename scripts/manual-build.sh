#!/bin/bash
# Manual build script for environments with Flutter SDK
# Run this on a machine with Flutter + Android SDK installed

set -e

echo "=========================================="
echo "BloodPulse Build Script - Task-004"
echo "=========================================="
echo ""

PROJECT_DIR="/shared/build/artifacts/bloodpulse"
RESULTS_DIR="$PROJECT_DIR/test-results"

echo "Project: $PROJECT_DIR"
echo "Results: $RESULTS_DIR"
echo ""

mkdir -p "$RESULTS_DIR"

cd "$PROJECT_DIR"

echo "Step 1: Clean previous build..."
flutter clean

echo ""
echo "Step 2: Get dependencies..."
flutter pub get

echo ""
echo "Step 3: Analyze code..."
flutter analyze --write "$RESULTS_DIR/analyze.log"

echo ""
echo "Step 4: Run tests..."
flutter test --reporter json > "$RESULTS_DIR/test-results.json" 2>&1 || true

echo ""
echo "Step 5: Build release APK..."
flutter build apk --release --target-platform android-arm64 2>&1 | tee "$RESULTS_DIR/build.log"

if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo ""
    echo "✅ BUILD SUCCESSFUL"
    echo ""
    cp "build/app/outputs/flutter-apk/app-release.apk" "$RESULTS_DIR/app-release-final.apk"
    echo "APK saved to: $RESULTS_DIR/app-release-final.apk"
    echo ""
    
    # Deploy to Appetize if token provided
    if [ -n "$APPETIZE_TOKEN" ]; then
        echo "Deploying to Appetize..."
        ./scripts/deploy-appetize.sh "$RESULTS_DIR/app-release-final.apk" "$APPETIZE_TOKEN"
    fi
    
    echo ""
    echo "=========================================="
    echo "BUILD COMPLETE"
    echo "=========================================="
else
    echo ""
    echo "❌ BUILD FAILED"
    echo "Check $RESULTS_DIR/build.log for details"
    exit 1
fi
