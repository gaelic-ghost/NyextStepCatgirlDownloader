import AppKit
import SwiftUI

@main
struct NCDApp: App {
    @NSApplicationDelegateAdaptor(NCDAppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            NCDSettingsView()
        }
    }
}
