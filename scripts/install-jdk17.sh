#!/bin/bash

# JDK 17 Installation Script for Android SDK
# This script installs OpenJDK 17 required for Android SDK tools

set -e

echo "=== Installing OpenJDK 17 for Android SDK ==="

# Check if JDK 17 is already installed
if java -version 2>&1 | grep -q "17"; then
    echo "JDK 17 is already installed"
    java -version
else
    echo "Installing OpenJDK 17..."
    
    # Update package list
    sudo apt-get update
    
    # Install OpenJDK 17
    sudo apt-get install -y openjdk-17-jdk
    
    # Set JAVA_HOME
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    export PATH=$JAVA_HOME/bin:$PATH
    
    # Add to bashrc for persistence
    echo "" >> ~/.bashrc
    echo "# Java 17 for Android SDK" >> ~/.bashrc
    echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" >> ~/.bashrc
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.bashrc
    
    echo "JDK 17 installed successfully!"
    java -version
fi

echo ""
echo "JAVA_HOME set to: $JAVA_HOME"
echo ""
echo "You can now run the Android SDK installation:"
echo "  bash scripts/install-android-sdk.sh"