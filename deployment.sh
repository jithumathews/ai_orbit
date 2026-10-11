#!/bin/bash
# ====================================================================
# AI ORBIT — Vercel Deployment & Build Script
# Automatically installs Flutter SDK on Vercel build servers,
# resolves dependencies, builds Flutter Web for release, and
# sets up SPA routing & 3D universe assets.
# ====================================================================

set -e

echo "🚀 [AI Orbit] Starting Vercel deployment pipeline..."

# 1. Install or locate Flutter SDK
if command -v flutter &> /dev/null; then
    echo "✅ [AI Orbit] Flutter found in system PATH."
else
    echo "📦 [AI Orbit] Flutter not found. Installing Flutter SDK (stable channel)..."
    FLUTTER_DIR="$HOME/flutter_sdk"
    if [ ! -d "$FLUTTER_DIR" ]; then
        git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_DIR"
    fi
    export PATH="$PATH:$FLUTTER_DIR/bin"
fi

echo "ℹ️ [AI Orbit] Flutter version:"
flutter --version

# 2. Configure Flutter Web
echo "🔧 [AI Orbit] Enabling Flutter Web..."
flutter config --enable-web

# 3. Fetch dependencies
echo "📦 [AI Orbit] Fetching Flutter dependencies..."
flutter pub get

# 4. Build Flutter Web for Release
echo "⚡ [AI Orbit] Building Flutter Web (Release mode)..."
flutter build web --release --no-tree-shake-icons

# 5. Verify & copy extra assets
echo "🌌 [AI Orbit] Synchronizing web assets..."
if [ -f "web/universe.html" ]; then
    cp web/universe.html build/web/universe.html
    echo "✅ [AI Orbit] universe.html copied to build/web/."
fi

echo "🎉 [AI Orbit] Build completed successfully! Output ready in build/web/."
