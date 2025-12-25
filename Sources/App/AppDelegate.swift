import AppKit
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var appController: AppController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Log.info("Application did finish launching. bundleURL=\(Bundle.main.bundleURL.path)")
        if !Bootstrapper.shouldContinueInProcess() {
            Log.info("Exiting bootstrap process after launching app bundle.")
            NSApp.terminate(nil)
            return
        }

        // Auto-register as a login item (macOS 13+).
        // Only register if not already registered to avoid duplicate entries.
        let loginItemStatus = SMAppService.mainApp.status
        if loginItemStatus == .notRegistered {
            do {
                try SMAppService.mainApp.register()
                Log.info("Login item registered. status=\(SMAppService.mainApp.status.rawValue)")
            } catch {
                Log.error("Failed to register login item: \(error)")
            }
        } else {
            Log.info("Login item already registered. status=\(loginItemStatus.rawValue)")
        }

        // Disable Command+Q
        disableCommandQ()

        appController = AppController()
    }

    private func disableCommandQ() {
        // Remove the Quit menu item's key equivalent
        if let appMenu = NSApp.mainMenu?.items.first?.submenu {
            for item in appMenu.items {
                if item.action == #selector(NSApplication.terminate(_:)) {
                    item.keyEquivalent = ""
                }
            }
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Prevent Command+Q from quitting the app
        Log.info("Terminate request blocked")
        return .terminateCancel
    }
}
