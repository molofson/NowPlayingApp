import Foundation
import SwiftUI

@MainActor
final class MusicStateModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var trackTitle: String = "-"
    @Published var trackArtist: String = "-"

    private var timer: Timer?

    var playerStateTitle: String {
        isPlaying ? "Playing" : "Not Playing"
    }

    var trackInfo: String {
        if trackTitle == "-" && trackArtist == "-" {
            return "No track information"
        }
        return "\(trackTitle) — \(trackArtist)"
    }

    func startPolling(interval: TimeInterval = 2.0) {
        stopPolling()
        // first immediate check
        Task { await updateMusicState() }
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { await self?.updateMusicState() }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    func updateMusicState() async {
        let script = "tell application \"Music\"\n if it is running then\n set t to player state\n if t is playing then\n set s to \"PLAYING\"\n else\n set s to \"NOT_PLAYING\"\n end if\n try\n set tt to name of current track\n set ar to artist of current track\n on error\n set tt to \"-\"\n set ar to \"-\"\n end try\n return s & "\"|\"" & tt & "\"|\"" & ar\n else\n return "NOT_RUNNING| - | -"
 end if\nend tell"

        do {
            let task = Process()
            task.launchPath = "/usr/bin/osascript"
            task.arguments = ["-e", script]
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = Pipe()
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let out = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                // expected format: STATE|TITLE|ARTIST
                let parts = out.components(separatedBy: "|")
                if parts.count >= 3 {
                    let state = parts[0]
                    let title = parts[1]
                    let artist = parts[2]
                    DispatchQueue.main.async {
                        self.isPlaying = (state == "PLAYING")
                        self.trackTitle = title.isEmpty ? "-" : title
                        self.trackArtist = artist.isEmpty ? "-" : artist
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
