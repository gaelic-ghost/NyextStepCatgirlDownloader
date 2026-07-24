import SwiftUI

struct NCDImageCardControls: View {
    let historyDirection: NCDImageHistoryDirection
    let canNavigateHistory: Bool
    let isLoading: Bool
    let canShare: Bool
    let navigateHistory: () -> Void
    let reload: () -> Void
    let share: () -> Void

    var body: some View {
        GlassEffectContainer(spacing: 18) {
            HStack {
                if canNavigateHistory {
                    Button(action: navigateHistory) {
                        Image(systemName: historyDirection == .backward ? "chevron.backward" : "chevron.forward")
                            .frame(width: 18, height: 18)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .accessibilityLabel(historyDirection == .backward ? "Show previous image" : "Show latest image")
                } else {
                    Image(systemName: "chevron.backward")
                        .frame(width: 18, height: 18)
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 32)
                        .glassEffect(.regular.interactive(false), in: .capsule)
                        .accessibilityHidden(true)
                }

                Spacer()

                Button(action: reload) {
                    Label(isLoading ? "Loading" : "Reload", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .tint(.indigo)
                .disabled(isLoading)

                Spacer()

                Button(action: share) {
                    Image(systemName: "square.and.arrow.up")
                        .frame(width: 18, height: 18)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .disabled(!canShare)
                .accessibilityLabel("Share image")
            }
        }
    }
}
