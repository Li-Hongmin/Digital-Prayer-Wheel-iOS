#!/bin/bash

# Build IPA script for Digital Prayer Wheel iOS
# Usage: ./build-ipa.sh

set -e

echo "🔨 Building Digital Prayer Wheel for AltStore..."

# Configuration
SCHEME_NAME="Digital-Prayer-Wheel-iOS"
CONFIGURATION="Release"
BUILD_DIR="./build"
ARCHIVE_PATH="$BUILD_DIR/app.xcarchive"
EXPORT_PATH="$BUILD_DIR/ipa"
EXPORT_OPTIONS="./altstore-config/ExportOptions.plist"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build archive
echo "📦 Creating archive..."
xcodebuild -scheme "$SCHEME_NAME" \
  -configuration "$CONFIGURATION" \
  -archivePath "$ARCHIVE_PATH" \
  archive

# Export IPA
echo "📤 Exporting IPA..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS"

# Find the generated IPA
IPA_FILE=$(find "$EXPORT_PATH" -name "*.ipa" | head -n 1)

if [ -f "$IPA_FILE" ]; then
    # Get version from Info.plist
    VERSION=$(defaults read "$(pwd)/$ARCHIVE_PATH/Info.plist" ApplicationProperties | \
              plutil -extract CFBundleShortVersionString raw -)

    # Rename IPA with version
    VERSIONED_IPA="$BUILD_DIR/Digital-Prayer-Wheel-v$VERSION.ipa"
    cp "$IPA_FILE" "$VERSIONED_IPA"

    echo "✅ Build successful!"
    echo "📱 IPA file created: $VERSIONED_IPA"

    # Show file size
    SIZE=$(du -h "$VERSIONED_IPA" | cut -f1)
    echo "📊 File size: $SIZE"

    echo ""
    echo "Next steps:"
    echo "1. Upload IPA to GitHub releases/"
    echo "2. Update apps.json with the download URL"
    echo "3. Commit and push to GitHub"
else
    echo "❌ Error: IPA file not found"
    exit 1
fi
