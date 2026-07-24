import AppKit
import SwiftUI

@MainActor
final class NCDStatusItemController: NSObject, NSPopoverDelegate {
    private let session = NCDImageSession()
    private let popover = NSPopover()
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func install() {
        guard let button = statusItem.button else {
            return
        }

        button.image = NSImage(systemSymbolName: "cat.fill", accessibilityDescription: "NyextStep Catgirl Downloader")
        button.target = self
        button.action = #selector(togglePopover)

        popover.behavior = .transient
        popover.delegate = self
        popover.contentSize = NSSize(width: 420, height: 520)
        popover.contentViewController = NSHostingController(rootView: NCDPopoverView(session: session))
    }

    @objc private func togglePopover() {
        popover.isShown ? popover.performClose(nil) : showPopover()
    }

    func showPopover() {
        guard let button = statusItem.button else {
            return
        }

        if !popover.isShown {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }

        NSApp.activate(ignoringOtherApps: true)
        session.revealCurrentImage()
    }
}
