import AppKit
import Carbon

/// 全域熱鍵管理 — 支援動態更換
final class HotkeyManager {
    static let shared = HotkeyManager()

    private var eventHotKey: EventHotKeyRef?
    private var handlerInstalled = false
    var onHotkey: (() -> Void)?

    private init() {
        // 監聽設定變更，自動重新註冊
        NotificationCenter.default.addObserver(
            forName: SettingsManager.hotkeyDidChange, object: nil, queue: .main
        ) { [weak self] _ in
            self?.reregister()
        }
    }

    func register() {
        let settings = SettingsManager.shared
        registerKey(keyCode: settings.hotkeyKeyCode, modifiers: settings.hotkeyModifiers)
    }

    func reregister() {
        unregister()
        register()
    }

    func unregister() {
        if let ref = eventHotKey {
            UnregisterEventHotKey(ref)
            eventHotKey = nil
        }
    }

    private func registerKey(keyCode: UInt32, modifiers: UInt32) {
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x50535452) // "PSTR"
        hotKeyID.id = 1

        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID,
                                          GetApplicationEventTarget(), 0, &hotKeyRef)
        if status == noErr {
            self.eventHotKey = hotKeyRef
        }

        // 只安裝一次 handler
        if !handlerInstalled {
            var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                           eventKind: UInt32(kEventHotKeyPressed))
            InstallEventHandler(GetApplicationEventTarget(), { _, event, _ -> OSStatus in
                HotkeyManager.shared.onHotkey?()
                return noErr
            }, 1, &eventType, nil, nil)
            handlerInstalled = true
        }
    }
}
