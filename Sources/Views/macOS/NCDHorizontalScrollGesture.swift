import AppKit
import SwiftUI

struct NCDHorizontalScrollGesture: NSViewRepresentable {
    @MainActor
    final class Coordinator {
        let view = NSView()
        var scrollLeft: () -> Void
        var scrollRight: () -> Void

        private var eventMonitor: Any?
        private var accumulatedHorizontalDelta = 0.0
        private var hasRecognizedGesture = false

        init(scrollLeft: @escaping () -> Void, scrollRight: @escaping () -> Void) {
            self.scrollLeft = scrollLeft
            self.scrollRight = scrollRight
        }

        func installMonitorIfNeeded() {
            guard eventMonitor == nil else {
                return
            }

            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [weak self] event in
                guard let self, self.receives(event) else {
                    return event
                }

                return self.handle(event) ? nil : event
            }
        }

        func removeMonitor() {
            if let eventMonitor {
                NSEvent.removeMonitor(eventMonitor)
                self.eventMonitor = nil
            }
        }

        private func receives(_ event: NSEvent) -> Bool {
            guard let window = view.window, event.window === window else {
                return false
            }

            let point = view.convert(event.locationInWindow, from: nil)
            return view.bounds.contains(point)
        }

        private func handle(_ event: NSEvent) -> Bool {
            let horizontalDelta = event.scrollingDeltaX
            guard abs(horizontalDelta) > abs(event.scrollingDeltaY) else {
                return false
            }

            accumulatedHorizontalDelta += horizontalDelta
            guard !hasRecognizedGesture, abs(accumulatedHorizontalDelta) >= 48 else {
                return true
            }

            hasRecognizedGesture = true
            if accumulatedHorizontalDelta < 0 {
                scrollLeft()
            } else {
                scrollRight()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.accumulatedHorizontalDelta = 0
                self?.hasRecognizedGesture = false
            }
            return true
        }
    }

    let scrollLeft: () -> Void
    let scrollRight: () -> Void

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        coordinator.removeMonitor()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(scrollLeft: scrollLeft, scrollRight: scrollRight)
    }

    func makeNSView(context: Context) -> NSView {
        context.coordinator.view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.scrollLeft = scrollLeft
        context.coordinator.scrollRight = scrollRight
        context.coordinator.installMonitorIfNeeded()
    }
}
