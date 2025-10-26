import Foundation
import SwiftUI

final class MusicStateModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var trackTitle: String = "-"
    @Published var trackArtist: String = "-"
    @Published var positionSeconds: Double = 0
    @Published var durationSeconds: Double = 0
    @Published var hasLocation: Bool = false
    // diagnostics
    @Published var appleScriptDiag: String = "(not run)"
    @Published var privateAPIDiag: String = "(not run)"
    @Published var mediaPlayerDiag: String = "(not run)"
    @Published var musicKitDiag: String = "(not run)"

    // parsed AppleScript fields
    @Published var appleScriptState: String = ""
    @Published var appleScriptTitle: String = ""
    @Published var appleScriptArtist: String = ""
    @Published var appleScriptPosition: String = "0"
    @Published var appleScriptDuration: String = "0"

    private var timer: Timer?

    var playerStateTitle: String {
        isPlaying ? "Playing" : "Not Playing"
    }

    var trackInfo: String {
        if isPlaying && !hasLocation {
            return "Streaming — metadata unavailable"
        }
        if trackTitle == "-" && trackArtist == "-" {
            return "No track information"
        }
        return "\(trackTitle) — \(trackArtist)"
    }

    var trackTimeDisplay: String {
        guard durationSeconds > 0 else { return "-" }
        func fmt(_ s: Double) -> String {
            let i = Int(s)
            let mm = i / 60
            let ss = i % 60
            return String(format: "%d:%02d", mm, ss)
        }
        return "\(fmt(positionSeconds)) / \(fmt(durationSeconds))"
    }

    func startPolling(interval: TimeInterval = 2.0) {
        stopPolling()
        Task { await updateMusicState() }
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { await self?.updateMusicState() }
        }
        if let t = timer { RunLoop.main.add(t, forMode: .common) }
    }

    // MARK: Diagnostics
    func runAppleScriptDiagnostic() async {
        // reuse the same AppleScript but return the raw output
        let script = """
        tell application "Music"
            if it is running then
                set t to player state
                if t is playing then
                    set s to "PLAYING"
                else
                    set s to "NOT_PLAYING"
                end if
                try
                    set tt to name of current track
                on error
                    set tt to ""
                end try
                try
                    set ar to artist of current track
                on error
                    set ar to ""
                end try
                try
                    set pos to player position
                on error
                    set pos to 0
                end try
                try
                    set dur to duration of current track
                on error
                    set dur to 0
                end try
                try
                    set hasLoc to (location of current track is not missing value)
                on error
                    set hasLoc to false
                end try
                return s & "|" & tt & "|" & ar & "|" & pos & "|" & dur & "|" & (hasLoc as string)
            else
                return "NOT_RUNNING||||0|0|false"
            end if
        end tell
        """

        do {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            task.arguments = ["-e", script]
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = Pipe()
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let out = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "(no output)"
            // parse fields: state|title|artist|pos|dur|hasLoc
            let parts = out.components(separatedBy: "|")
            var parsedState = ""
            var parsedTitle = ""
            var parsedArtist = ""
            var parsedPos = "0"
            var parsedDur = "0"
            var parsedHasLoc = "false"
            if parts.count >= 6 {
                parsedState = parts[0]
                parsedTitle = parts[1]
                parsedArtist = parts[2]
                parsedPos = parts[3]
                parsedDur = parts[4]
                parsedHasLoc = parts[5]
            }
            DispatchQueue.main.async {
                self.appleScriptDiag = out
                self.appleScriptState = parsedState
                self.appleScriptTitle = parsedTitle.isEmpty ? "-" : parsedTitle
                self.appleScriptArtist = parsedArtist.isEmpty ? "-" : parsedArtist
                self.appleScriptPosition = parsedPos
                self.appleScriptDuration = parsedDur
                self.hasLocation = (parsedHasLoc.lowercased() == "true")
            }
        } catch {
            DispatchQueue.main.async {
                self.appleScriptDiag = "(failed to run osascript)\n\(error)"
            }
        }
    }

    func runPrivateAPIDiagnostic() async {
        // First, gather AppleScript-based info (so Private APIs panel can show both)
        await runAppleScriptDiagnostic()

        // Check for presence of common private frameworks that apps sometimes inspect
        let candidates = [
            "/System/Library/PrivateFrameworks/MediaRemote.framework",
            "/System/Library/PrivateFrameworks/MediaPlaybackCore.framework",
            "/System/Library/PrivateFrameworks/MPUFoundation.framework"
        ]
        var found: [String] = []
        for p in candidates {
            if FileManager.default.fileExists(atPath: p) {
                found.append(p)
            }
        }
        var report: String
        if found.isEmpty {
            report = "No known private media frameworks found on expected paths."
        } else {
            report = "Found private frameworks:\n" + found.joined(separator: "\n")
        }
        // include AppleScript snapshot
        let asSnapshot = "AppleScript: state=\(appleScriptState) title=\(appleScriptTitle) artist=\(appleScriptArtist) pos=\(appleScriptPosition) dur=\(appleScriptDuration) hasLocation=\(hasLocation)"
        let combined = asSnapshot + "\n\n" + report
        DispatchQueue.main.async {
            self.privateAPIDiag = combined
        }
    }

    func runMediaPlayerDiagnostic() {
        // Without importing MediaPlayer, check at runtime for MPNowPlayingInfoCenter
        let cls = NSClassFromString("MPNowPlayingInfoCenter")
        let available = (cls != nil)
        DispatchQueue.main.async {
            self.mediaPlayerDiag = available ? "MPNowPlayingInfoCenter available (class present)" : "MPNowPlayingInfoCenter NOT available"
        }
    }

    func runMusicKitDiagnostic() {
        // Placeholder: MusicKit integration requires entitlements and developer configuration
        let report = "MusicKit: not implemented — requires MusicKit entitlements and user tokens"
        DispatchQueue.main.async {
            self.musicKitDiag = report
        }
    }

    /// Run AppleScript and Private-API checks first, then MediaPlayer check (a, b, then d)
    func startDiagnosticsABThenD() {
        Task {
            await runAppleScriptDiagnostic()
            await runPrivateAPIDiagnostic()
            // run MediaPlayer after a short delay to simulate ordering
            try? await Task.sleep(nanoseconds: 500_000_000)
            self.runMediaPlayerDiagnostic()
            self.runMusicKitDiagnostic()
        }
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    func updateMusicState() async {
        let script = """
        tell application "Music"
            if it is running then
                set t to player state
                if t is playing then
                    set s to "PLAYING"
                else
                    set s to "NOT_PLAYING"
                end if
                -- guarded reads: use try blocks and explicit defaults
                try
                    set tt to name of current track
                on error
                    set tt to ""
                end try
                try
                    set ar to artist of current track
                on error
                    set ar to ""
                end try
                try
                    set pos to player position
                on error
                    set pos to 0
                end try
                try
                    set dur to duration of current track
                on error
                    set dur to 0
                end try
                try
                    set hasLoc to (location of current track is not missing value)
                on error
                    set hasLoc to false
                end try
                return s & "|" & tt & "|" & ar & "|" & pos & "|" & dur & "|" & (hasLoc as string)
            else
                return "NOT_RUNNING||||0|0|false"
            end if
        end tell
        """

        do {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            task.arguments = ["-e", script]
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = Pipe()
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let out = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                let parts = out.components(separatedBy: "|")
                if parts.count >= 6 {
                    let state = parts[0]
                    let title = parts[1]
                    let artist = parts[2]
                    let pos = Double(parts[3]) ?? 0
                    let dur = Double(parts[4]) ?? 0
                    let hasLocStr = parts[5].lowercased()
                    let hasLoc = (hasLocStr == "true")
                    DispatchQueue.main.async {
                        self.isPlaying = (state == "PLAYING")
                        self.trackTitle = title.isEmpty ? "-" : title
                        self.trackArtist = artist.isEmpty ? "-" : artist
                        self.positionSeconds = pos
                        self.durationSeconds = dur
                        self.hasLocation = hasLoc
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isPlaying = false
                self.trackTitle = "-"
                self.trackArtist = "-"
            }
        }
    }

    deinit {
        stopPolling()
    }
}
