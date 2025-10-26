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

    func testConfiguredManagerReturnsFakeToken() async throws {
        let mgr = MusicKitManager.shared
        mgr.clear()
        mgr.configure(developerToken: "DEV_TOKEN")
        XCTAssertTrue(mgr.isConfigured)
        let token = try await mgr.requestUserToken()
        XCTAssertEqual(token, "FAKE_USER_TOKEN")
    }
}
