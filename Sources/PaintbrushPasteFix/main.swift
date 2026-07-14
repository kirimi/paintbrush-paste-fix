import AppKit
import PasteFixCore

private let paintbrushBundleIdentifier = "com.soggywaffles.paintbrush"

@MainActor
final class PasteFixAppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var timer: Timer?
    private var lastObservedChangeCount = -1
    private var isRewritingPasteboard = false
    private var statusMenuItem: NSMenuItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configureStatusItem()

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(frontmostApplicationChanged),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )

        timer = Timer.scheduledTimer(
            timeInterval: 0.4,
            target: self,
            selector: #selector(timerFired),
            userInfo: nil,
            repeats: true
        )

        checkPasteboard(force: true)
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = NSImage(
            systemSymbolName: "photo.badge.checkmark",
            accessibilityDescription: "Paintbrush Paste Fix"
        )
        item.button?.toolTip = "Fix Retina image pasting in Paintbrush 2.6"

        let menu = NSMenu()
        let status = NSMenuItem(title: "Waiting for an image", action: nil, keyEquivalent: "")
        status.isEnabled = false
        statusMenuItem = status
        menu.addItem(status)
        menu.addItem(.separator())
        menu.addItem(
            withTitle: "Fix Clipboard Now",
            action: #selector(fixPasteboardNow),
            keyEquivalent: ""
        ).target = self
        menu.addItem(
            withTitle: "Open Paintbrush",
            action: #selector(openPaintbrush),
            keyEquivalent: ""
        ).target = self
        menu.addItem(.separator())
        menu.addItem(
            withTitle: "Quit",
            action: #selector(quit),
            keyEquivalent: "q"
        ).target = self

        item.menu = menu
        statusItem = item
    }

    @objc private func frontmostApplicationChanged() {
        checkPasteboard(force: true)
    }

    @objc private func timerFired() {
        checkPasteboard(force: false)
    }

    private func checkPasteboard(force: Bool) {
        guard isPaintbrushFrontmost else {
            return
        }

        let pasteboard = NSPasteboard.general
        guard force || pasteboard.changeCount != lastObservedChangeCount else {
            return
        }

        lastObservedChangeCount = pasteboard.changeCount
        normalizePasteboard(pasteboard)
    }

    private var isPaintbrushFrontmost: Bool {
        NSWorkspace.shared.frontmostApplication?.bundleIdentifier?.lowercased()
            == paintbrushBundleIdentifier
    }

    private func normalizePasteboard(_ pasteboard: NSPasteboard) {
        guard !isRewritingPasteboard else {
            return
        }

        guard let image = NSImage(pasteboard: pasteboard) else {
            statusMenuItem?.title = "No image on the clipboard"
            return
        }

        guard let normalized = ClipboardImageNormalizer.normalize(image) else {
            statusMenuItem?.title = "Could not read the clipboard image"
            return
        }

        isRewritingPasteboard = true
        pasteboard.clearContents()
        pasteboard.setData(normalized.pngData, forType: .png)
        pasteboard.setData(normalized.tiffData, forType: .tiff)
        lastObservedChangeCount = pasteboard.changeCount
        isRewritingPasteboard = false

        let width = Int(normalized.targetPixelSize.width)
        let height = Int(normalized.targetPixelSize.height)
        statusMenuItem?.title = normalized.wasDownsampled
            ? "Retina image fixed: \(width)×\(height)"
            : "Image ready: \(width)×\(height)"
    }

    @objc private func fixPasteboardNow() {
        lastObservedChangeCount = -1
        normalizePasteboard(NSPasteboard.general)
    }

    @objc private func openPaintbrush() {
        guard let url = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: paintbrushBundleIdentifier
        ) else {
            statusMenuItem?.title = "Paintbrush 2.6 was not found"
            return
        }

        NSWorkspace.shared.openApplication(
            at: url,
            configuration: NSWorkspace.OpenConfiguration()
        )
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

@main
@MainActor
enum PaintbrushPasteFixMain {
    private static let delegate = PasteFixAppDelegate()

    static func main() {
        let application = NSApplication.shared
        application.delegate = delegate
        application.run()
    }
}
