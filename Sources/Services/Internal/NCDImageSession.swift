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
            previousImage = currentImage
            currentImage = nextImage
            audioCuePlayer.playReveal()
        } catch {
            errorMessage = error.localizedDescription
        }

        withAnimation(.easeOut(duration: 0.18)) {
            isShutterClosed = false
        }
        isLoading = false
    }

    func goBack() {
        guard let previousImage else {
            return
        }

        currentImage = previousImage
        self.previousImage = nil
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
