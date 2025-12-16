import Foundation

enum Log {
    private static let queue = DispatchQueue(label: "AlwaysHaveAPlan.Log")

    static func info(_ message: String) {
        write("INFO", message)
    }

    static func error(_ message: String) {
        write("ERROR", message)
    }

    private static func write(_ level: String, _ message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let line = "\(timestamp) [\(level)] \(message)\n"

        // Always print to stderr as well (useful when launched from Terminal).
        FileHandle.standardError.write(line.data(using: .utf8) ?? Data())

        queue.async {
            let fm = FileManager.default
            let logsDir = fm.homeDirectoryForCurrentUser
                .appendingPathComponent("Library", isDirectory: true)
                .appendingPathComponent("Logs", isDirectory: true)
            let logURL = logsDir.appendingPathComponent("AlwaysHaveAPlan.log")
            do {
                try fm.createDirectory(at: logsDir, withIntermediateDirectories: true)
                if !fm.fileExists(atPath: logURL.path) {
                    fm.createFile(atPath: logURL.path, contents: nil)
                }
                let fh = try FileHandle(forWritingTo: logURL)
                defer { try? fh.close() }
                try fh.seekToEnd()
                fh.write(line.data(using: .utf8) ?? Data())
            } catch {
                // Ignore file logging errors.
            }
        }
    }
}

