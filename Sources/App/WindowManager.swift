import AppKit
import SwiftUI
import EventKit

final class WindowManager {
    private var floatingWindowController: NSWindowController?
    private let floatingModel = FloatingPromptModel()
    private var autoHideWorkItem: DispatchWorkItem?

    func showFloatingPrompt(onCheck: @escaping () -> Void) {
        autoHideWorkItem?.cancel()
        autoHideWorkItem = nil

        if floatingWindowController == nil {
            Log.info("Showing floating prompt window")
            let hosting = NSHostingView(rootView: FloatingPromptView(model: floatingModel, onCheck: onCheck))

            let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
            let size = NSSize(width: screen.width * 0.7, height: screen.height * 0.7)
            let origin = NSPoint(
                x: screen.midX - size.width / 2,
                y: screen.midY - size.height / 2
            )

            let window = NSWindow(
                contentRect: NSRect(origin: origin, size: size),
                styleMask: [.titled, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.isReleasedWhenClosed = false
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            window.contentView = hosting
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)

            floatingWindowController = NSWindowController(window: window)
        } else {
            Log.info("Reusing existing floating prompt window")
            if let window = floatingWindowController?.window {
                window.contentView = NSHostingView(rootView: FloatingPromptView(model: floatingModel, onCheck: onCheck))
            }
            NSApp.activate(ignoringOtherApps: true)
            floatingWindowController?.showWindow(nil)
        }
    }

    func showFloatingEvents(_ events: [EKEvent], autoHideAfter seconds: TimeInterval) {
        Log.info("Showing floating events autoHideAfter=\(seconds)s count=\(events.count)")
        updateFloatingEvents(events)
        showFloatingPrompt(onCheck: {})

        autoHideWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            guard let self else { return }
            // Only auto-hide if we still have events showing.
            guard !self.floatingModel.currentEvents.isEmpty else { return }
            self.floatingModel.currentEvents = []
            self.floatingWindowController?.window?.orderOut(nil)
            Log.info("Auto-hid floating events window")
        }
        autoHideWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: item)
    }

    func updateFloatingEvents(_ events: [EKEvent]) {
        floatingModel.currentEvents = events
    }

    func hideFloatingWindow() {
        autoHideWorkItem?.cancel()
        autoHideWorkItem = nil
        floatingModel.currentEvents = []
        floatingWindowController?.window?.orderOut(nil)
        Log.info("Hid floating window")
    }

    private func closeFloatingPrompt() {
        floatingWindowController?.close()
        floatingWindowController = nil
    }
}

final class FloatingPromptModel: ObservableObject {
    @Published var currentEvents: [EKEvent] = []
}
