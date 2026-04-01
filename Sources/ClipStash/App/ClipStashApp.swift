import SwiftUI

@main
struct PasterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
        } label: {
            Image(systemName: "clipboard")
        }
        .menuBarExtraStyle(.menu)

        Settings {
            EmptyView()
        }
    }
}
