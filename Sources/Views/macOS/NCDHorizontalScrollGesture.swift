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
        private var resetWorkItem: DispatchWorkItem?

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
            resetWorkItem?.cancel()
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

            beginGestureIfNeeded(for: event)
            if event.momentumPhase != [] {
                resetWorkItem?.cancel()
            }

            accumulatedHorizontalDelta += horizontalDelta
            guard !hasRecognizedGesture, abs(accumulatedHorizontalDelta) >= 48 else {
                scheduleResetAfterGestureEndIfNeeded(for: event)
                return true
            }

            hasRecognizedGesture = true
            if accumulatedHorizontalDelta < 0 {
                scrollLeft()
            } else {
                scrollRight()
            }

            scheduleResetAfterGestureEndIfNeeded(for: event)
            return true
        }

        private func beginGestureIfNeeded(for event: NSEvent) {
            guard event.phase == .began else {
                return
            }

            resetWorkItem?.cancel()
            resetWorkItem = nil
            accumulatedHorizontalDelta = 0
            hasRecognizedGesture = false
        }

        private func scheduleResetAfterGestureEndIfNeeded(for event: NSEvent) {
            let hasEnded = event.phase == .ended || event.phase == .cancelled || event.momentumPhase == .ended || event.momentumPhase == .cancelled
            let isDiscreteScroll = event.phase == [] && event.momentumPhase == []
            guard hasEnded || isDiscreteScroll else {
                return
            }

            resetWorkItem?.cancel()
            let resetWorkItem = DispatchWorkItem { [weak self] in
                self?.accumulatedHorizontalDelta = 0
                self?.hasRecognizedGesture = false
            }
            self.resetWorkItem = resetWorkItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: resetWorkItem)
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
