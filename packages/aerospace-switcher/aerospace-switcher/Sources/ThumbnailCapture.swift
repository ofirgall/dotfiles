import AppKit
import CoreGraphics

enum ThumbnailCapture {
    static func captureThumbnail(windowId: UInt32) -> NSImage? {
        let cgId = CGWindowID(windowId)
        guard let cgImage = CGWindowListCreateImage(
            .null,
            .optionIncludingWindow,
            cgId,
            [.boundsIgnoreFraming, .bestResolution]
        ) else {
            return nil
        }
        return NSImage(cgImage: cgImage, size: NSSize(
            width: cgImage.width,
            height: cgImage.height
        ))
    }

    static func appIcon(for appName: String) -> NSImage? {
        NSWorkspace.shared.runningApplications
            .first { $0.localizedName == appName }?
            .icon
    }

    static func populateThumbnails(_ windows: inout [WindowInfo]) {
        for i in windows.indices {
            windows[i].thumbnail = captureThumbnail(windowId: windows[i].windowId)
            windows[i].appIcon = appIcon(for: windows[i].appName)
        }
    }
}
