import AppKit
import QuartzCore

private let thumbWidth: CGFloat = 200
private let thumbHeight: CGFloat = 140
private let itemSpacing: CGFloat = 16
private let panelPadding: CGFloat = 24
private let labelHeight: CGFloat = 24
private let iconSize: CGFloat = 20
private let selectionInset: CGFloat = 4
private let cornerRadius: CGFloat = 12

final class SwitcherPanel {
    private let panel: NSPanel
    private let contentView: NSView
    private var itemViews: [ItemView] = []
    private(set) var selectedIndex: Int = 0
    private let windows: [WindowInfo]

    init(windows: [WindowInfo], selectedIndex: Int) {
        self.windows = windows
        self.selectedIndex = selectedIndex

        let itemWidth = thumbWidth + selectionInset * 2
        let totalWidth = CGFloat(windows.count) * itemWidth
            + CGFloat(max(0, windows.count - 1)) * itemSpacing
            + panelPadding * 2
        let totalHeight = thumbHeight + selectionInset * 2 + labelHeight + panelPadding * 2

        let frame = NSRect(x: 0, y: 0, width: totalWidth, height: totalHeight)

        panel = NSPanel(
            contentRect: frame,
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .statusBar + 1
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hasShadow = true

        let bg = NSVisualEffectView(frame: frame)
        bg.material = .hudWindow
        bg.state = .active
        bg.blendingMode = .behindWindow
        bg.wantsLayer = true
        bg.layer?.cornerRadius = cornerRadius
        bg.layer?.masksToBounds = true
        panel.contentView = bg
        contentView = bg

        var x = panelPadding
        for (i, win) in windows.enumerated() {
            let itemFrame = NSRect(
                x: x,
                y: panelPadding + labelHeight,
                width: itemWidth,
                height: thumbHeight + selectionInset * 2
            )
            let item = ItemView(frame: itemFrame, window: win, selected: i == selectedIndex)
            contentView.addSubview(item)
            itemViews.append(item)

            let label = makeLabel(
                text: win.appName,
                icon: win.appIcon,
                frame: NSRect(x: x, y: panelPadding - 4, width: itemWidth, height: labelHeight)
            )
            contentView.addSubview(label)

            x += itemWidth + itemSpacing
        }
    }

    func show() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let panelSize = panel.frame.size
        let origin = NSPoint(
            x: screenFrame.midX - panelSize.width / 2,
            y: screenFrame.midY - panelSize.height / 2
        )
        panel.setFrameOrigin(origin)
        panel.alphaValue = 0
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.12
            panel.animator().alphaValue = 1
        }
    }

    func dismiss() {
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.08
            panel.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            self?.panel.orderOut(nil)
        })
    }

    func cycleNext() {
        guard !windows.isEmpty else { return }
        updateSelection((selectedIndex + 1) % windows.count)
    }

    func cyclePrev() {
        guard !windows.isEmpty else { return }
        updateSelection((selectedIndex - 1 + windows.count) % windows.count)
    }

    var selectedWindowId: UInt32? {
        guard selectedIndex < windows.count else { return nil }
        return windows[selectedIndex].windowId
    }

    private func updateSelection(_ newIndex: Int) {
        itemViews[selectedIndex].setSelected(false)
        selectedIndex = newIndex
        itemViews[selectedIndex].setSelected(true)
    }

    private func makeLabel(text: String, icon: NSImage?, frame: NSRect) -> NSView {
        let container = NSView(frame: frame)

        let iconView = NSImageView(frame: NSRect(
            x: (frame.width - iconSize - 6 - min(CGFloat(text.count) * 7, frame.width - iconSize - 12)) / 2,
            y: (labelHeight - iconSize) / 2,
            width: iconSize,
            height: iconSize
        ))
        if let icon {
            iconView.image = icon
        }
        container.addSubview(iconView)

        let tf = NSTextField(labelWithString: text)
        tf.font = .systemFont(ofSize: 12, weight: .medium)
        tf.textColor = .white
        tf.alignment = .left
        tf.lineBreakMode = .byTruncatingTail
        tf.frame = NSRect(
            x: iconView.frame.maxX + 4,
            y: (labelHeight - 16) / 2,
            width: frame.width - iconView.frame.maxX - 8,
            height: 16
        )
        container.addSubview(tf)

        return container
    }
}

private final class ItemView: NSView {
    private let borderLayer = CAShapeLayer()
    private var isSelected: Bool

    init(frame: NSRect, window: WindowInfo, selected: Bool) {
        self.isSelected = selected
        super.init(frame: frame)
        wantsLayer = true

        let thumbFrame = NSRect(
            x: selectionInset,
            y: selectionInset,
            width: thumbWidth,
            height: thumbHeight
        )

        let imageView = NSImageView(frame: thumbFrame)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.wantsLayer = true
        imageView.layer?.cornerRadius = 6
        imageView.layer?.masksToBounds = true
        imageView.layer?.backgroundColor = NSColor(white: 0.15, alpha: 1).cgColor

        if let thumb = window.thumbnail {
            imageView.image = thumb
        } else if let icon = window.appIcon {
            imageView.image = icon
            imageView.imageScaling = .scaleProportionallyDown
        }
        addSubview(imageView)

        borderLayer.path = CGPath(
            roundedRect: bounds.insetBy(dx: 1, dy: 1),
            cornerWidth: 8,
            cornerHeight: 8,
            transform: nil
        )
        borderLayer.fillColor = nil
        borderLayer.lineWidth = 3
        updateBorderColor()
        layer?.addSublayer(borderLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func setSelected(_ selected: Bool) {
        isSelected = selected
        updateBorderColor()
    }

    private func updateBorderColor() {
        borderLayer.strokeColor = isSelected
            ? NSColor.controlAccentColor.cgColor
            : CGColor.clear
    }
}
