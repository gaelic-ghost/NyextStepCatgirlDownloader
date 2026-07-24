import AppKit
import SwiftUI

struct NCDImageCardView: View {
    let image: NSImage?
    let isLoading: Bool
    let errorMessage: String?
    let isShutterClosed: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, .purple.opacity(0.65), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if let image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            } else if isLoading {
                ProgressView("Finding a catgirl…")
                    .tint(.white)
            } else if let errorMessage {
                ContentUnavailableView("Image unavailable", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                    .padding(32)
            }

            NCDCameraShutterView(isClosed: isShutterClosed)
                .allowsHitTesting(false)
        }
        .clipShape(.rect(cornerRadius: 24))
        .padding(12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(image == nil ? "No catgirl image loaded" : "Current catgirl image")
    }
}
