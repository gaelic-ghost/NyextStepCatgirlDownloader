import AppKit
import SwiftUI

struct NCDImageCardView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let image: NSImage?
    let imageID: UUID?
    let isLoading: Bool
    let errorMessage: String?
    let isShutterClosed: Bool
    let imageTransitionDirection: NCDImageTransitionDirection
    let controls: NCDImageCardControls

    private let frameShape = NCDChamferedRectangle(cut: 28)
    private let imageShape = NCDChamferedRectangle(cut: 21)

    private var imageTransition: AnyTransition {
        switch imageTransitionDirection {
            case .backward:
                .asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .move(edge: .trailing).combined(with: .opacity))
            case .forward:
                .asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity))
        }
    }

    var body: some View {
        ZStack {
            frameShape
                .fill(.clear)
                .glassEffect(.regular, in: frameShape)

            imageContent
                .clipShape(imageShape)
                .padding(8)

            NCDCameraShutterView(isClosed: isShutterClosed)
                .clipShape(imageShape)
                .padding(8)
                .allowsHitTesting(false)

            VStack {
                Spacer()
                controls
                    .padding(24)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(image == nil ? "No catgirl image loaded" : "Current catgirl image")
    }

    private var imageContent: some View {
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
                    .id(imageID)
                    .transition(imageTransition)
            } else if isLoading {
                ProgressView("Finding a catgirl…")
                    .tint(.white)
            } else if let errorMessage {
                ContentUnavailableView(
                    "Image unavailable",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
                .padding(32)
            }
        }
        .transaction { transaction in
            if reduceMotion {
                transaction.disablesAnimations = true
            }
        }
    }
}
