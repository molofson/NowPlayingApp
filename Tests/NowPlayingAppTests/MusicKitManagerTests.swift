import XCTest
@testable import NowPlayingApp

final class MusicKitManagerTests: XCTestCase {
    func testUnconfiguredManager() {
        let mgr = MusicKitManager.shared
        mgr.clear()
        XCTAssertFalse(mgr.isConfigured)
        XCTAssertThrowsError(try { _ = try await mgr.requestUserToken() }())
    }
}
