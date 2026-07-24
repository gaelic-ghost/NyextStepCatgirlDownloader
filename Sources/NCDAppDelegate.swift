import AppKit

@MainActor
final class NCDAppDelegate: NSObject, NSApplicationDelegate {
    private let statusItemController = NCDStatusItemController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItemController.install()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls where NCDURLCommand(url: url) == .open {
            statusItemController.showPopover()
        }
    }
}
