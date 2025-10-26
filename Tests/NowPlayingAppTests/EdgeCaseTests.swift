import XCTest
@testable import NowPlayingApp

final class EdgeCaseTests: XCTestCase {
    func testZeroDurationFormatting() {
        let model = MusicStateModel()
        model.positionSeconds = 30
        model.durationSeconds = 0
        // When duration is zero, display only position
        XCTAssertEqual(model.trackTimeDisplay, "0:30 / 0:00")
    }

    func testTitleNoArtist() {
        let m = MusicStateModel()
        m.isPlaying = true
        m.hasLocation = true
        m.trackTitle = "Solo"
        m.trackArtist = ""
        XCTAssertEqual(m.trackInfo, "Solo — Artist unknown")
    }
}
