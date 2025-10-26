import XCTest
@testable import NowPlayingApp

final class MusicKitManagerTests: XCTestCase {
    func testUnconfiguredManager() async throws {
        let mgr = MusicKitManager.shared
        mgr.clear()
        XCTAssertFalse(mgr.isConfigured)
        do {
            _ = try await mgr.requestUserToken()
            XCTFail("Expected requestUserToken to throw when unconfigured")
        } catch {
            // expected
        }
    }
}
