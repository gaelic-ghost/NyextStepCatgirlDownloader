import Foundation

enum NCDURLCommand: Equatable {
    case open

    init?(url: URL) {
        guard url.scheme?.lowercased() == "nyextstep", url.host?.lowercased() == "open", url.path.isEmpty, url.query == nil else {
            return nil
        }

        self = .open
    }
}
