#!/bin/bash

# Android SDK Installation Script for Flutter Development
# This script installs the Android SDK command-line tools for building Flutter apps

set -e

echo "=== Android SDK Installation for Flutter ==="

# Set up environment variables
export ANDROID_SDK_ROOT=$HOME/android-sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

# Create Android SDK directory
mkdir -p $ANDROID_SDK_ROOT

# Download Android command-line tools
echo "1. Downloading Android command-line tools..."
CMDLINE_TOOLS_VERSION="13114758"  # Latest as of 2025
CMDLINE_TOOLS_ZIP="commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip"

cd /tmp
# Remove any existing download
rm -f $CMDLINE_TOOLS_ZIP
wget -q --show-progress "https://dl.google.com/android/repository/$CMDLINE_TOOLS_ZIP"

# Verify download
if [ ! -f "$CMDLINE_TOOLS_ZIP" ]; then
    echo "Error: Failed to download command-line tools"
    exit 1
fi

# Check file integrity
FILE_SIZE=$(stat -c%s "$CMDLINE_TOOLS_ZIP")
echo "Downloaded file size: $FILE_SIZE bytes"
if [ "$FILE_SIZE" -lt 100000000 ]; then
    echo "Error: Downloaded file is too small, possibly corrupted"
    exit 1
fi

# Extract command-line tools
echo "2. Extracting command-line tools..."
unzip -q $CMDLINE_TOOLS_ZIP -d $ANDROID_SDK_ROOT/
rm $CMDLINE_TOOLS_ZIP

# Move to correct directory structure
mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/latest
mv $ANDROID_SDK_ROOT/cmdline-tools/* $ANDROID_SDK_ROOT/cmdline-tools/latest/ 2>/dev/null || true

# Accept licenses
echo "3. Accepting Android SDK licenses..."
yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --licenses >/dev/null 2>&1 || true

# Install required SDK packages
echo "4. Installing required SDK packages..."
$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0" \
    "sources;android-34"

echo "5. Installing additional build tools..."
$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager \
    "platforms;android-33" \
    "build-tools;33.0.2"

# Configure Flutter
echo "6. Configuring Flutter SDK..."
cd /home/matt/FINAPP/Receipt\ Organizer
./flutter/bin/flutter config --android-sdk $ANDROID_SDK_ROOT

# Verify installation
echo "7. Verifying installation..."
./flutter/bin/flutter doctor

# Add to bashrc for persistence
echo "8. Adding environment variables to ~/.bashrc..."
cat >> ~/.bashrc << 'EOL'

# Android SDK for Flutter
export ANDROID_SDK_ROOT=$HOME/android-sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools
EOL

echo "=== Android SDK Installation Complete ==="
echo ""
echo "Environment variables added to ~/.bashrc:"
echo "  ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"
echo "  ANDROID_HOME=$ANDROID_HOME"
echo ""
echo "To use in current session, run:"
echo "  source ~/.bashrc"
echo ""
echo "You can now build Android APKs with:"
echo "  flutter build apk --debug"
echo "  flutter build apk --release"