import AppKit

enum Bootstrapper {
    /// Returns true to continue in current process.
    /// If not already running from an app bundle, attempts to create+launch one; only returns false if launch succeeded.
    static func shouldContinueInProcess() -> Bool {
        let bundleURL = Bundle.main.bundleURL
        if bundleURL.pathExtension == "app" {
            return true
        }

        do {
            let appURL = try createOrUpdateAppBundle()
            let config = NSWorkspace.OpenConfiguration()
            config.activates = true
            config.addsToRecentItems = false
            let semaphore = DispatchSemaphore(value: 0)
            var launched = false
            NSWorkspace.shared.openApplication(at: appURL, configuration: config) { _, error in
                if let error {
                    NSLog("Failed to launch bundled app: \(error)")
                    launched = false
                } else {
                    launched = true
                }
                semaphore.signal()
            }
            _ = semaphore.wait(timeout: .now() + 2)
            if !launched {
                return true
            }

            // Verify the launched app is actually running before terminating this process.
            let bundleID = "com.chriszou.alwayshaveaplan"
            let deadline = Date().addingTimeInterval(2)
            while Date() < deadline {
                if !NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).isEmpty {
                    return false
                }
                Thread.sleep(forTimeInterval: 0.1)
            }

            return true
        } catch {
            // If bundling fails, keep running as CLI (no calendar prompt).
            NSLog("Bootstrapper failed: \(error)")
            return true
        }
    }

    private static func createOrUpdateAppBundle() throws -> URL {
        let fm = FileManager.default
        // Keep everything local to the current directory so `swift run` doesn't write into ~/Applications.
        // Default: ./run/AlwaysHaveAPlan.app
        let baseDir = URL(fileURLWithPath: fm.currentDirectoryPath, isDirectory: true)
            .appendingPathComponent("run", isDirectory: true)
        let appURL = baseDir.appendingPathComponent("AlwaysHaveAPlan.app", isDirectory: true)
        let contentsURL = appURL.appendingPathComponent("Contents", isDirectory: true)
        let macOSURL = contentsURL.appendingPathComponent("MacOS", isDirectory: true)
        let resourcesURL = contentsURL.appendingPathComponent("Resources", isDirectory: true)

        try fm.createDirectory(at: baseDir, withIntermediateDirectories: true)
        try fm.createDirectory(at: macOSURL, withIntermediateDirectories: true)
        try fm.createDirectory(at: resourcesURL, withIntermediateDirectories: true)

        let exePath = URL(fileURLWithPath: CommandLine.arguments[0]).standardizedFileURL
        let targetExeURL = macOSURL.appendingPathComponent("AlwaysHaveAPlan")

        if fm.fileExists(atPath: targetExeURL.path) {
            try fm.removeItem(at: targetExeURL)
        }
        try fm.copyItem(at: exePath, to: targetExeURL)
        try fm.setAttributes([.posixPermissions: 0o755], ofItemAtPath: targetExeURL.path)

        let plistURL = contentsURL.appendingPathComponent("Info.plist")
        try infoPlistData().write(to: plistURL, options: .atomic)

        // Copy AppIcon.icns if it exists
        if let iconURL = Bundle.module.url(forResource: "AppIcon", withExtension: "icns") {
            let targetIconURL = resourcesURL.appendingPathComponent("AppIcon.icns")
            if fm.fileExists(atPath: targetIconURL.path) {
                try fm.removeItem(at: targetIconURL)
            }
            try fm.copyItem(at: iconURL, to: targetIconURL)
        }

        return appURL
    }

    private static func infoPlistData() throws -> Data {
        if let url = Bundle.module.url(forResource: "InfoTemplate", withExtension: "plist"),
           let data = try? Data(contentsOf: url) {
            return data
        }

        let plist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>CFBundleIdentifier</key>
            <string>com.chriszou.alwayshaveaplan</string>
            <key>CFBundleName</key>
            <string>AlwaysHaveAPlan</string>
            <key>CFBundleDisplayName</key>
            <string>AlwaysHaveAPlan</string>
            <key>CFBundleExecutable</key>
            <string>AlwaysHaveAPlan</string>
            <key>CFBundlePackageType</key>
            <string>APPL</string>
            <key>CFBundleIconFile</key>
            <string>AppIcon</string>
            <key>NSCalendarsUsageDescription</key>
            <string>需要访问你的日历以在解锁时显示当前日程。</string>
        </dict>
        </plist>
        """
        return Data(plist.utf8)
    }
}
