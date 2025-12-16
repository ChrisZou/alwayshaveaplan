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
        // This is idempotent and will keep the app running in background on future logins.
        do {
            try SMAppService.mainApp.register()
            Log.info("Login item register attempted. status=\(SMAppService.mainApp.status.rawValue)")
        } catch {
            Log.error("Failed to register login item: \(error)")
        }

        appController = AppController()
    }
}
