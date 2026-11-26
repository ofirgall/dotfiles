import AppKit
import CoreGraphics

final class KeyMonitor {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    var onConfirm: (() -> Void)?
    var onEscape: (() -> Void)?
    var onArrowRight: (() -> Void)?
    var onArrowLeft: (() -> Void)?

    func start() {
        let mask: CGEventMask = 1 << CGEventType.keyDown.rawValue

        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard type == .keyDown else { return Unmanaged.passRetained(event) }
            let monitor = Unmanaged<KeyMonitor>.fromOpaque(refcon!).takeUnretainedValue()
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            switch keyCode {
            case 36, 76: // Return, Numpad Enter
                DispatchQueue.main.async { monitor.onConfirm?() }
                return nil
            case 53: // Escape
                DispatchQueue.main.async { monitor.onEscape?() }
                return nil
            case 124, 37: // Right arrow, l
                DispatchQueue.main.async { monitor.onArrowRight?() }
                return nil
            case 123, 4: // Left arrow, h
                DispatchQueue.main.async { monitor.onArrowLeft?() }
                return nil
            case 125, 38: // Down arrow, j (next)
                DispatchQueue.main.async { monitor.onArrowRight?() }
                return nil
            case 126, 40: // Up arrow, k (prev)
                DispatchQueue.main.async { monitor.onArrowLeft?() }
                return nil
            default:
                return Unmanaged.passRetained(event)
            }
        }

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: selfPtr
        )

        guard let tap = eventTap else { return }

        runLoopSource = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
    }
}
