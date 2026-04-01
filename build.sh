#!/bin/bash
# Build ClipStash.app
set -e

SDK=$(xcrun --sdk macosx --show-sdk-path)
APP_DIR="ClipStash.app/Contents"

echo "🔨 Compiling..."
swiftc \
  -sdk "$SDK" \
  -target arm64-apple-macos13.0 \
  -parse-as-library \
  -lsqlite3 \
  -framework AppKit \
  -framework SwiftUI \
  -framework Carbon \
  -O \
  -o "$APP_DIR/MacOS/ClipStash" \
  Sources/ClipStash/Models/ClipItem.swift \
  Sources/ClipStash/Core/DatabaseManager.swift \
  Sources/ClipStash/Core/ClipboardMonitor.swift \
  Sources/ClipStash/Core/HotkeyManager.swift \
  Sources/ClipStash/Core/PasteService.swift \
  Sources/ClipStash/Core/SettingsManager.swift \
  Sources/ClipStash/Views/SearchViewModel.swift \
  Sources/ClipStash/Views/SearchPanelView.swift \
  Sources/ClipStash/Views/SearchPanelController.swift \
  Sources/ClipStash/Views/MenuBarView.swift \
  Sources/ClipStash/App/AppDelegate.swift \
  Sources/ClipStash/App/ClipStashApp.swift

echo "✅ Built: ClipStash.app"
echo "   Run: open ClipStash.app"
