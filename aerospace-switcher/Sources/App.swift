import AppKit
import Foundation

@main
enum SwitcherApp {
    static func main() {
        guard InstanceLock.acquireOrSignal() else {
            return
        }

        guard let conn = AeroSpaceConnection.connect() else {
            InstanceLock.release()
            return
        }

        var result = WindowQuery.fetch(conn: conn)
        guard result.windows.count > 1 else {
            conn.run(["focus", "--wrap-around", "dfs-next"])
            InstanceLock.release()
            return
        }

        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        ThumbnailCapture.populateThumbnails(&result.windows)

        let nextIndex = (result.focusedIndex + 1) % result.windows.count
        let panel = SwitcherPanel(windows: result.windows, selectedIndex: nextIndex)
        let keyMonitor = KeyMonitor()

        func confirmSelection() {
            keyMonitor.stop()
            if let wid = panel.selectedWindowId {
                if let c = AeroSpaceConnection.connect() {
                    c.run(["focus", "--window-id", "\(wid)"])
                }
            }
            panel.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                InstanceLock.release()
                NSApp.terminate(nil)
            }
        }

        func cancel() {
            keyMonitor.stop()
            panel.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                InstanceLock.release()
                NSApp.terminate(nil)
            }
        }

        // SIGUSR1: another Cmd+Tab press -> cycle to next window
        let sigCycle = DispatchSource.makeSignalSource(signal: SIGUSR1, queue: .main)
        signal(SIGUSR1, SIG_IGN)
        sigCycle.setEventHandler { panel.cycleNext() }
        sigCycle.resume()

        keyMonitor.onConfirm = { confirmSelection() }
        keyMonitor.onEscape = { cancel() }
        keyMonitor.onArrowRight = { panel.cycleNext() }
        keyMonitor.onArrowLeft = { panel.cyclePrev() }
        keyMonitor.start()

        panel.show()

        app.run()
    }
}
