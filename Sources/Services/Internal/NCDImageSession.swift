import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class NCDImageSession {
    private(set) var currentImage: NCDImage?
    private(set) var previousImage: NCDImage?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var isShutterClosed = false
    private(set) var historyDirection: NCDImageHistoryDirection = .backward
    private(set) var imageTransitionDirection: NCDImageTransitionDirection = .forward

    private let loadNextImage: () async throws -> NCDImage
    private let audioCuePlayer: NCDAudioCuePlayer

    init(
        loadNextImage: @escaping () async throws -> NCDImage = { try await NCDNekosMoeSource().loadImage() },
        audioCuePlayer: NCDAudioCuePlayer = NCDAudioCuePlayer()
    ) {
        self.loadNextImage = loadNextImage
        self.audioCuePlayer = audioCuePlayer
    }

    func reload() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil
        withAnimation(.easeIn(duration: 0.12)) {
            isShutterClosed = true
        }

        do {
            let nextImage = try await loadNextImage()
            imageTransitionDirection = .forward
            withAnimation(.snappy(duration: 0.32, extraBounce: 0)) {
                previousImage = currentImage
                currentImage = nextImage
                historyDirection = .backward
            }
            audioCuePlayer.playReveal()
        } catch {
            errorMessage = error.localizedDescription
        }

        withAnimation(.easeOut(duration: 0.18)) {
            isShutterClosed = false
        }
        isLoading = false
    }

    func navigateHistory() {
        guard let previousImage else {
            return
        }

        imageTransitionDirection = historyDirection == .backward ? .backward : .forward
        withAnimation(.snappy(duration: 0.32, extraBounce: 0)) {
            let displayedImage = currentImage
            currentImage = previousImage
            self.previousImage = displayedImage
            historyDirection = historyDirection == .backward ? .forward : .backward
        }
    }

    func navigateForwardOrReload() async {
        if historyDirection == .forward, previousImage != nil {
            navigateHistory()
        } else {
            await reload()
        }
    }

    func revealCurrentImage() {
        guard currentImage != nil else {
            Task { await reload() }
            return
        }

        audioCuePlayer.playReveal()
        withAnimation(.easeIn(duration: 0.12)) {
            isShutterClosed = true
        }
        withAnimation(.easeOut(duration: 0.18).delay(0.12)) {
            isShutterClosed = false
        }
    }
}

enum NCDImageHistoryDirection: Equatable {
    case backward
    case forward
}

enum NCDImageTransitionDirection: Equatable {
    case backward
    case forward
}
