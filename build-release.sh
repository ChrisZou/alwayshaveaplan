#!/bin/bash
set -e

echo "🔨 Building AlwaysHaveAPlan in Release mode..."
swift build -c release

echo "📦 Creating app bundle..."
rm -rf run/release/AlwaysHaveAPlan.app
mkdir -p run/release/AlwaysHaveAPlan.app/Contents/MacOS
mkdir -p run/release/AlwaysHaveAPlan.app/Contents/Resources

echo "📋 Copying executable..."
cp .build/release/AlwaysHaveAPlan run/release/AlwaysHaveAPlan.app/Contents/MacOS/AlwaysHaveAPlan
chmod +x run/release/AlwaysHaveAPlan.app/Contents/MacOS/AlwaysHaveAPlan

echo "📄 Copying Info.plist..."
cp Sources/App/Resources/InfoTemplate.plist run/release/AlwaysHaveAPlan.app/Contents/Info.plist

echo "🎨 Copying icon..."
cp Sources/App/Resources/AppIcon.icns run/release/AlwaysHaveAPlan.app/Contents/Resources/AppIcon.icns

echo "✅ Build complete! App bundle created at: run/release/AlwaysHaveAPlan.app"
echo "📊 App size: $(du -sh run/release/AlwaysHaveAPlan.app | cut -f1)"
