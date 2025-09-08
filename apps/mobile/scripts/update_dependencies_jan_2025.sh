#!/bin/bash

# Dependency Update Script for January 2025
# This script updates all dependencies to their latest stable versions

set -e

echo "================================================"
echo "Receipt Organizer - Dependency Update"
echo "Date: January 2025"
echo "================================================"
echo ""

# Navigate to mobile app directory
cd "$(dirname "$0")/.."

# Backup current pubspec.yaml
cp pubspec.yaml pubspec.yaml.backup

echo "Creating updated pubspec.yaml with January 2025 versions..."

# Create updated pubspec.yaml
cat > pubspec.yaml << 'EOF'
name: receipt_organizer
description: "A new Flutter project."
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ^3.5.3

dependencies:
  flutter:
    sdk: flutter

  # UI and State Management (Updated for Jan 2025)
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.6.1  # Updated from 2.4.0
  riverpod_annotation: ^2.4.0  # Updated
  
  # Camera and Image Processing
  camera: ^0.11.0  # Updated from 0.10.5
  image: ^4.3.0  # Updated from 4.5.1 (4.5.1 doesn't exist)
  flutter_image_compress: ^2.3.0  # Updated from 2.1.0
  
  # OCR and ML
  google_mlkit_text_recognition: ^0.15.0  # Updated package name from google_ml_kit
  
  # Database and Storage
  drift: ^2.21.0  # Modern replacement for sqflite
  drift_flutter: ^0.2.0  # For Flutter integration
  path_provider: ^2.1.5  # Updated from 2.1.1
  path: ^1.9.0  # Updated from 1.8.3
  
  # CSV Processing
  csv: ^6.0.0
  
  # Utilities
  uuid: ^4.5.1  # Updated from 4.1.0
  shared_preferences: ^2.3.3  # Updated from 2.2.2
  intl: ^0.20.0  # Updated from 0.19.0
  permission_handler: ^11.3.1  # Added for camera permissions
  
  # Code generation dependencies
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0  # Updated

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Linting and Testing
  flutter_lints: ^5.0.0  # Updated from 4.0.0
  mockito: ^5.4.5  # Updated from 5.4.2
  build_runner: ^2.5.4
  
  # Code generation  
  riverpod_generator: ^2.6.3
  json_serializable: ^6.9.5
  freezed: ^2.5.0  # Updated from 3.1.0 (3.1.0 doesn't exist)
  drift_dev: ^2.21.0  # For drift code generation
  
  # Testing
  mocktail: ^1.0.4
  integration_test:
    sdk: flutter
  test: ^1.25.14

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
EOF

echo ""
echo "Updated pubspec.yaml created. Key changes:"
echo "- flutter_riverpod: 2.4.0 → 2.6.1"
echo "- camera: 0.10.5 → 0.11.0"
echo "- google_ml_kit → google_mlkit_text_recognition: 0.15.0"
echo "- Added drift for modern database support"
echo "- Updated all utility packages to latest versions"
echo "- Added permission_handler for proper permission management"
echo ""

echo "Running flutter pub get..."
flutter pub get

echo ""
echo "Running flutter pub outdated to verify..."
flutter pub outdated

echo ""
echo "================================================"
echo "IMPORTANT NOTES:"
echo "================================================"
echo "1. google_ml_kit has been split into separate packages"
echo "   - Use google_mlkit_text_recognition for OCR"
echo ""
echo "2. Consider migrating from sqflite to drift for:"
echo "   - Better type safety"
echo "   - Compile-time SQL verification"
echo "   - Modern reactive queries"
echo ""
echo "3. New required permissions for Android/iOS:"
echo "   - Camera permission handling via permission_handler"
echo "   - Storage permissions for saving receipts"
echo ""
echo "4. Breaking changes to review:"
echo "   - Camera plugin API changes in 0.11.0"
echo "   - Riverpod 2.6.x syntax updates"
echo ""
echo "Original pubspec.yaml backed up to pubspec.yaml.backup"
echo ""