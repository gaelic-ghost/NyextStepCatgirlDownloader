import SwiftUI

struct NCDPopoverView: View {
    @Bindable var session: NCDImageSession

    let onIdealSizeChange: (CGSize) -> Void

    private var idealSize: CGSize {
        let width = 460.0
        guard let image = session.currentImage?.image, image.size.width > 0 else {
            return CGSize(width: width, height: width)
        }

        let height = min(max(width * image.size.height / image.size.width, 300), 680)
        return CGSize(width: width, height: height)
    }

    var body: some View {
        NCDImageCardView(
            image: session.currentImage?.image,
            imageID: session.currentImage?.id,
            isLoading: session.isLoading,
            errorMessage: session.errorMessage,
            isShutterClosed: session.isShutterClosed,
            imageTransitionDirection: session.imageTransitionDirection,
            controls: NCDImageCardControls(
                historyDirection: session.historyDirection,
                canNavigateHistory: session.previousImage != nil,
                isLoading: session.isLoading,
                canShare: session.currentImage?.image != nil,
                navigateHistory: session.navigateHistory,
                reload: { Task { await session.reload() } },
                share: {
                    guard let image = session.currentImage?.image else {
                        return
                    }

                    NCDShareService.present(image: image)
                }
            )
        )
        .frame(width: idealSize.width, height: idealSize.height)
        .onAppear { onIdealSizeChange(idealSize) }
        .onChange(of: session.currentImage?.id) { _, _ in
            onIdealSizeChange(idealSize)
        }
        .background {
            NCDHorizontalScrollGesture(
                scrollLeft: { Task { await session.navigateForwardOrReload() } },
                scrollRight: session.navigateHistory
            )
        }
        .task {
            if session.currentImage == nil {
                await session.reload()
            }
        }
    }
}
