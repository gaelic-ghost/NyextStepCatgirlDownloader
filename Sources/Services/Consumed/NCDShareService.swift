import AppKit

@MainActor
enum NCDShareService {
    static func present(image: NSImage) {
        guard let contentView = NSApp.keyWindow?.contentView else {
            return
        }

        NSSharingServicePicker(items: [image]).show(
            relativeTo: contentView.bounds,
            of: contentView,
            preferredEdge: .minY
        )
    }
}
