import SwiftUI

struct NCDPopoverView: View {
    @Bindable var session: NCDImageSession

    var body: some View {
        ZStack {
            NCDImageCardView(
                image: session.currentImage?.image,
                isLoading: session.isLoading,
                errorMessage: session.errorMessage,
                isShutterClosed: session.isShutterClosed
            )

            VStack {
                Spacer()

                GlassEffectContainer(spacing: 16) {
                    HStack {
                        Button(action: session.goBack) {
                            Image(systemName: "chevron.backward")
                                .frame(width: 18, height: 18)
                        }
                        .buttonStyle(.plain)
                        .padding(12)
                        .glassEffect(.regular.interactive(), in: .circle)
                        .disabled(session.previousImage == nil)
                        .accessibilityLabel("Show previous image")

                        Spacer()

                        Button {
                            Task { await session.reload() }
                        } label: {
                            Label(session.isLoading ? "Loading" : "Reload", systemImage: "arrow.clockwise")
                                .frame(minWidth: 96)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .glassEffect(.regular.interactive(), in: .capsule)
                        .disabled(session.isLoading)

                        Spacer()

                        if let image = session.currentImage {
                            Button {
                                guard let image = image.image else {
                                    return
                                }

                                NCDShareService.present(image: image)
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .frame(width: 18, height: 18)
                            }
                            .buttonStyle(.plain)
                            .padding(12)
                            .glassEffect(.regular.interactive(), in: .circle)
                            .accessibilityLabel("Share image")
                        } else {
                            Image(systemName: "square.and.arrow.up")
                                .frame(width: 18, height: 18)
                                .padding(12)
                                .glassEffect(in: .circle)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .padding(20)
            }
        }
        .frame(width: 420, height: 520)
        .task {
            if session.currentImage == nil {
                await session.reload()
            }
        }
    }
}
