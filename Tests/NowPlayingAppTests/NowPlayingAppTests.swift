import XCTest
@testable import NowPlayingApp

final class NowPlayingAppTests: XCTestCase {
    func testTrackTimeFormatting() {
        let model = MusicStateModel()
    model.positionSeconds = 75 // 1:15
    model.durationSeconds = 240 // 4:00
        XCTAssertEqual(model.trackTimeDisplay, "1:15 / 4:00")
    }
}
