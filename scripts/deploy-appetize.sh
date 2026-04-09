#!/bin/bash
# Deploy to Appetize.io script
# Usage: ./deploy-appetize.sh <apk_path> [token]

set -e

APK_PATH="${1:-build/app/outputs/flutter-apk/app-release.apk}"
APPETIZE_TOKEN="${2:-tok_cuf5fuflofenc3bitfbt3w6b2m}"
PLATFORM="${3:-android}"

if [ ! -f "$APK_PATH" ]; then
    echo "ERROR: APK not found at $APK_PATH"
    echo "Usage: $0 <apk_path> [token]"
    exit 1
fi

echo "Deploying to Appetize.io..."
echo "APK: $APK_PATH"
echo "Platform: $PLATFORM"

# Upload to Appetize
curl -X POST \
  https://$APPETIZE_TOKEN@api.appetize.io/v1/apps \
  -F "file=@$APK_PATH" \
  -F "platform=$PLATFORM" \
  -o appetize-response.json

echo ""
echo "Appetize response saved to appetize-response.json"
cat appetize-response.json | jq -r '.publicURL' 2>/dev/null || cat appetize-response.json
