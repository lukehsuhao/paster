import Foundation
import ServiceManagement
import AppKit
import Carbon

/// 持久化設定管理
final class SettingsManager {
    static let shared = SettingsManager()

    private let defaults = UserDefaults.standard

    /// 設定變更通知
    static let hotkeyDidChange = Notification.Name("SettingsManager.hotkeyDidChange")
    static let menuBarIconDidChange = Notification.Name("SettingsManager.menuBarIconDidChange")

    private init() {}

    // MARK: - 開機啟動

    var launchAtLogin: Bool {
        get { defaults.bool(forKey: "launchAtLogin") }
        set {
            defaults.set(newValue, forKey: "launchAtLogin")
            if #available(macOS 13.0, *) {
                do {
                    if newValue {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                } catch {
                    // 如果註冊失敗（例如非正式 .app），回退設定
                    defaults.set(false, forKey: "launchAtLogin")
                }
            }
        }
    }

    // MARK: - 選單列圖示

    var showMenuBarIcon: Bool {
        get { defaults.object(forKey: "showMenuBarIcon") == nil ? true : defaults.bool(forKey: "showMenuBarIcon") }
        set {
            defaults.set(newValue, forKey: "showMenuBarIcon")
            NotificationCenter.default.post(name: Self.menuBarIconDidChange, object: nil)
        }
    }

    // MARK: - 熱鍵

    /// Carbon modifier flags（cmdKey, shiftKey, optionKey, controlKey）
    var hotkeyModifiers: UInt32 {
        get {
            let v = defaults.integer(forKey: "hotkeyModifiers")
            // 預設 Cmd+Shift
            return v == 0 && defaults.object(forKey: "hotkeyModifiers") == nil
                ? UInt32(cmdKey | shiftKey) : UInt32(v)
        }
        set { defaults.set(Int(newValue), forKey: "hotkeyModifiers") }
    }

    /// Virtual key code
    var hotkeyKeyCode: UInt32 {
        get {
            let v = defaults.integer(forKey: "hotkeyKeyCode")
            // 預設 V (keyCode 9)
            return v == 0 && defaults.object(forKey: "hotkeyKeyCode") == nil ? 9 : UInt32(v)
        }
        set { defaults.set(Int(newValue), forKey: "hotkeyKeyCode") }
    }

    /// 人類可讀的熱鍵字串
    var hotkeyDisplayString: String {
        var parts: [String] = []
        let mods = hotkeyModifiers
        if mods & UInt32(controlKey) != 0 { parts.append("⌃") }
        if mods & UInt32(optionKey) != 0 { parts.append("⌥") }
        if mods & UInt32(shiftKey) != 0 { parts.append("⇧") }
        if mods & UInt32(cmdKey) != 0 { parts.append("⌘") }
        parts.append(keyCodeToString(hotkeyKeyCode))
        return parts.joined()
    }

    func setHotkey(keyCode: UInt32, modifiers: UInt32) {
        hotkeyKeyCode = keyCode
        hotkeyModifiers = modifiers
        NotificationCenter.default.post(name: Self.hotkeyDidChange, object: nil)
    }

    // MARK: - 歷史

    var retentionDays: Int {
        get {
            let v = defaults.integer(forKey: "retentionDays")
            return v == 0 && defaults.object(forKey: "retentionDays") == nil ? 30 : v
        }
        set { defaults.set(newValue, forKey: "retentionDays") }
    }

    var maxItems: Int {
        get {
            let v = defaults.integer(forKey: "maxItems")
            return v == 0 && defaults.object(forKey: "maxItems") == nil ? 5000 : v
        }
        set { defaults.set(newValue, forKey: "maxItems") }
    }

    // MARK: - 隱私

    var detectSensitive: Bool {
        get { defaults.object(forKey: "detectSensitive") == nil ? true : defaults.bool(forKey: "detectSensitive") }
        set { defaults.set(newValue, forKey: "detectSensitive") }
    }
}

// MARK: - Key Code Mapping

func keyCodeToString(_ keyCode: UInt32) -> String {
    let map: [UInt32: String] = [
        0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
        8: "C", 9: "V", 10: "§", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
        16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6", 23: "5",
        24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0", 30: "]", 31: "O",
        32: "U", 33: "[", 34: "I", 35: "P", 36: "↩", 37: "L", 38: "J", 39: "'",
        40: "K", 41: ";", 42: "\\", 43: ",", 44: "/", 45: "N", 46: "M", 47: ".",
        48: "⇥", 49: "Space", 50: "`",
    ]
    return map[keyCode] ?? "Key\(keyCode)"
}

/// 把 NSEvent modifier flags 轉換為 Carbon modifier flags
func nsModifiersToCarbonModifiers(_ flags: NSEvent.ModifierFlags) -> UInt32 {
    var carbon: UInt32 = 0
    if flags.contains(.command) { carbon |= UInt32(cmdKey) }
    if flags.contains(.shift) { carbon |= UInt32(shiftKey) }
    if flags.contains(.option) { carbon |= UInt32(optionKey) }
    if flags.contains(.control) { carbon |= UInt32(controlKey) }
    return carbon
}
