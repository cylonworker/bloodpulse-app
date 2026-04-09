#!/bin/bash
# Deploy APK to Appetize.io for live demo

APK_PATH="${1:-build/app/outputs/flutter-apk/app-release.apk}"
APPETIZE_TOKEN="${APPETIZE_API_TOKEN:-$2}"

if [ -z "$APPETIZE_TOKEN" ]; then
    echo "❌ Error: Appetize API token required"
    echo "Usage: APPETIZE_API_TOKEN=your_token ./deploy-appetize.sh [apk_path]"
    exit 1
fi

if [ ! -f "$APK_PATH" ]; then
    echo "❌ Error: APK not found at $APK_PATH"
    exit 1
fi

echo "========================================"
echo "Deploying to Appetize.io"
echo "APK: $APK_PATH"
echo "Size: $(stat -f%z "$APK_PATH" 2>/dev/null || stat -c%s "$APK_PATH" 2>/dev/null) bytes"
echo "========================================"

# Upload to Appetize - try different auth formats
# Format 1: Bearer token in header
echo "Trying Bearer token format..."
curl -s -X POST \
  -H "Authorization: Bearer $APPETIZE_TOKEN" \
  -F "file=@$APK_PATH" \
  -F "platform=android" \
  -F "notes=BloodPulse Auth Fixed - $(date -u +'%Y-%m-%d %H:%M UTC')" \
  "https://api.appetize.io/v1/apps" | tee appetize-response.json

# Check if it worked
if ! grep -q "publicURL" appetize-response.json 2>/dev/null; then
    echo "Trying alternative format..."
    # Format 2: Token in query param
    curl -s -X POST \
      -F "file=@$APK_PATH" \
      -F "platform=android" \
      -F "notes=BloodPulse Auth Fixed - $(date -u +'%Y-%m-%d %H:%M UTC')" \
      "https://api.appetize.io/v1/apps?token=$APPETIZE_TOKEN" | tee appetize-response.json
fi

echo ""
echo "========================================"

# Parse response
if command -v jq &> /dev/null; then
    PUBLIC_URL=$(jq -r '.publicURL' appetize-response.json 2>/dev/null)
    APP_URL=$(jq -r '.appURL' appetize-response.json 2>/dev/null)
    
    if [ "$PUBLIC_URL" != "null" ] && [ -n "$PUBLIC_URL" ]; then
        echo "✅ SUCCESS! App deployed to Appetize"
        echo ""
        echo "🌐 Public URL: $PUBLIC_URL"
        echo "📱 App URL: $APP_URL"
        echo ""
        echo "Share this link for live demo:"
        echo "$PUBLIC_URL"
        
        # Save to results
        echo "appetize_url=$PUBLIC_URL" >> test-results/DEPLOYMENT.txt
        echo "appetize_app_url=$APP_URL" >> test-results/DEPLOYMENT.txt
        echo "deploy_time=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> test-results/DEPLOYMENT.txt
        
        exit 0
    else
        echo "❌ Deployment may have failed"
        cat appetize-response.json
        exit 1
    fi
else
    echo "Response saved to appetize-response.json"
    cat appetize-response.json
fi
