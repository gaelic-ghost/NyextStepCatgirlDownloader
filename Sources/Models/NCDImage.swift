import AppKit
import Foundation

struct NCDImage: Equatable, Identifiable {
    let data: Data
    let sourceURL: URL
    let suggestedFilename: String
    let id = UUID()

    var image: NSImage? {
        NSImage(data: data)
    }
}
