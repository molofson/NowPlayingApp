import XCTest
@testable import NowPlayingApp

final class ModelLogicTests: XCTestCase {
    func testPlayerStateTitle() {
        let m = MusicStateModel()
        m.isPlaying = true
        XCTAssertEqual(m.playerStateTitle, "Playing")
        m.isPlaying = false
        XCTAssertEqual(m.playerStateTitle, "Not Playing")
    }

    func testTrackInfo_noTrack() {
        let m = MusicStateModel()
        m.isPlaying = false
        m.trackTitle = "-"
        m.trackArtist = "-"
        XCTAssertEqual(m.trackInfo, "No track information")
    }

    func testTrackInfo_streaming() {
        let m = MusicStateModel()
        m.isPlaying = true
        m.hasLocation = false
        XCTAssertEqual(m.trackInfo, "Streaming — metadata unavailable")
    }

    func testTrackInfo_normal() {
        let m = MusicStateModel()
        m.isPlaying = true
        m.hasLocation = true
        m.trackTitle = "Song"
        m.trackArtist = "Artist"
        XCTAssertEqual(m.trackInfo, "Song — Artist")
    }
}
