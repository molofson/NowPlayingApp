import AppKit
import SwiftUI

// Minimal AppKit entry to host a SwiftUI view in a single window.
let app = NSApplication.shared
app.setActivationPolicy(.regular)

let model = MusicStateModel()
let contentView = ContentView().environmentObject(model)

let window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 900, height: 700),
    styleMask: [.titled, .closable, .miniaturizable, .resizable],
    backing: .buffered,
    defer: false
)

// Restore saved frame if present, otherwise center with default size
let kFrameKey = "NowPlayingWindowFrame"
if let saved = UserDefaults.standard.string(forKey: kFrameKey) {
    let rect = NSRectFromString(saved)
    window.setFrame(rect, display: false)
} else {
    window.center()
}
window.title = "Now Playing"
window.contentView = NSHostingView(rootView: contentView)
window.minSize = NSSize(width: 700, height: 400)
window.makeKeyAndOrderFront(nil)

// Observe window resize end to persist the frame
NotificationCenter.default.addObserver(forName: NSWindow.didEndLiveResizeNotification, object: window, queue: .main) { _ in
    let frameStr = NSStringFromRect(window.frame)
    UserDefaults.standard.set(frameStr, forKey: kFrameKey)
}

// Also persist on close
NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: .main) { _ in
    let frameStr = NSStringFromRect(window.frame)
    UserDefaults.standard.set(frameStr, forKey: kFrameKey)
}

// start polling after window appears
DispatchQueue.main.async {
    model.startPolling()
    // run diagnostics at startup
    model.startDiagnosticsABThenD()
}

app.activate(ignoringOtherApps: true)
app.run()
