import AppKit

struct WindowInfo {
    let windowId: UInt32
    let appName: String
    let windowTitle: String
    var thumbnail: NSImage?
    var appIcon: NSImage?
}

enum WindowQuery {
    struct Result {
        var windows: [WindowInfo]
        let focusedIndex: Int
    }

    static func fetch(conn: AeroSpaceConnection) -> Result {
        let focusedId = conn.query([
            "list-windows", "--focused", "--format", "%{window-id}"
        ]).flatMap { UInt32($0) }

        guard let output = conn.query([
            "list-windows", "--workspace", "focused",
            "--format", "%{window-id}\t%{app-name}\t%{window-title}"
        ]) else {
            return Result(windows: [], focusedIndex: 0)
        }

        let windows: [WindowInfo] = output.split(separator: "\n").compactMap { line in
            let parts = line.split(separator: "\t", maxSplits: 2)
            guard parts.count >= 2,
                  let wid = UInt32(parts[0]) else { return nil }
            let appName = String(parts[1])
            let title = parts.count > 2 ? String(parts[2]) : ""
            return WindowInfo(
                windowId: wid,
                appName: appName,
                windowTitle: title,
                thumbnail: nil,
                appIcon: nil
            )
        }

        let focusedIndex = windows.firstIndex(where: { $0.windowId == focusedId }) ?? 0
        return Result(windows: windows, focusedIndex: focusedIndex)
    }
}
