#!/bin/bash
# Build Paster.app
set -e

APP_DIR="Paster.app/Contents"
mkdir -p "$APP_DIR/MacOS" "$APP_DIR/Resources"

echo "🔨 Compiling Paster..."
swift build -c release

# 複製編譯產物到 .app bundle
cp .build/release/Paster "$APP_DIR/MacOS/Paster"

# 複製 ShortcutRecorder 資源檔
rm -rf "$APP_DIR/Resources/ShortcutRecorder_ShortcutRecorder.bundle"
cp -R .build/arm64-apple-macosx/release/ShortcutRecorder_ShortcutRecorder.bundle "$APP_DIR/Resources/"

# 用 "Paster Dev" 自簽證書簽名（TCC 權限在重新 build 後仍有效）
codesign -f -s "Developer ID Application: Hao Hsu (V6ZDDG5Z68)" --identifier "com.luke.paster" Paster.app

echo "✅ Built: Paster.app"
echo "   Run: open Paster.app"
echo ""
echo "   部署到 Applications："
echo "   cp -R Paster.app /Applications/Paster.app"
