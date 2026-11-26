import Foundation

private let pidPath = "/tmp/aerospace-switcher.pid"

enum InstanceLock {
    /// Returns true if we became the primary instance. Returns false if another
    /// instance was already running and we signaled it to cycle.
    static func acquireOrSignal() -> Bool {
        if let existing = readExistingPid(), kill(existing, 0) == 0 {
            kill(existing, SIGUSR1)
            return false
        }
        writePid()
        return true
    }

    static func release() {
        try? FileManager.default.removeItem(atPath: pidPath)
    }

    private static func readExistingPid() -> pid_t? {
        guard let content = try? String(contentsOfFile: pidPath, encoding: .utf8) else {
            return nil
        }
        return pid_t(content.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private static func writePid() {
        let pid = ProcessInfo.processInfo.processIdentifier
        try? "\(pid)".write(toFile: pidPath, atomically: true, encoding: .utf8)
    }
}
