import AppKit
import Foundation

/// 快速貼上服務
/// 記住前一個 App，貼上時先切回去再模擬 Cmd+V
final class PasteService {
    static let shared = PasteService()
    private var hasCheckedPermission = false

    /// 開啟搜尋面板前的前景 App
    var previousApp: NSRunningApplication?

    private init() {}

    /// 將 ClipItem 寫入系統剪貼簿
    func writeToClipboard(_ item: ClipItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.contentType {
        case .text, .rtf:
            if let text = item.textContent {
                pasteboard.setString(text, forType: .string)
            }
        case .url:
            if let text = item.textContent {
                pasteboard.setString(text, forType: .string)
                pasteboard.setString(text, forType: .URL)
            }
        case .filePath:
            if let text = item.textContent {
                pasteboard.setString(text, forType: .string)
            }
        case .image:
            if let data = item.imageData {
                pasteboard.setData(data, forType: .png)
            }
        }
    }

    /// 一鍵完成：寫入剪貼簿 → 切回前一個 App → 模擬 Cmd+V
    func pasteItem(_ item: ClipItem) {
        writeToClipboard(item)

        guard AXIsProcessTrusted() else {
            if !hasCheckedPermission {
                hasCheckedPermission = true
                let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
                let options = [key: true] as CFDictionary
                AXIsProcessTrustedWithOptions(options)
            }
            return
        }

        // 先切回前一個 App
        if let app = previousApp {
            app.activate(options: [])
        }

        // 等 App 切換完成再模擬按鍵
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let source = CGEventSource(stateID: .combinedSessionState)

            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
            keyDown?.flags = .maskCommand
            keyDown?.post(tap: .cghidEventTap)

            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
            keyUp?.flags = .maskCommand
            keyUp?.post(tap: .cghidEventTap)
        }
    }
}
