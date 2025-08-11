#!/bin/bash

# iOS Archive Build Script for App Store Submission
# This script builds and archives the iOS app for App Store distribution

echo "🚀 Starting iOS Archive Build for App Store..."

# Clean the project
echo "🧹 Cleaning project..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build iOS release
echo "🔨 Building iOS release..."
flutter build ios --release

# Open Xcode workspace
echo "📱 Opening Xcode workspace..."
open ios/Runner.xcworkspace

echo "✅ Build completed successfully!"
echo ""
echo "📋 Next steps in Xcode:"
echo "1. Select 'Runner' scheme"
echo "2. Select 'Any iOS Device' as build target"
echo "3. Go to Product → Archive"
echo "4. Once archived, click 'Distribute App'"
echo "5. Select 'App Store Connect'"
echo "6. Follow the distribution wizard"
echo ""
echo "📝 Don't forget to include the review notes from APP_STORE_REVIEW_NOTES.md" 