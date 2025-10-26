import Foundation

/// Lightweight MusicKit scaffolding.
/// This manager intentionally does not require entitlements at compile-time.
/// It provides clear runtime diagnostics and placeholders for integrating developer tokens.
final class MusicKitManager {
    static let shared = MusicKitManager()

    // Developer token should be fetched from your server and not embedded in the app.
    private var developerToken: String?
    private var userToken: String?

    var isConfigured: Bool {
        return developerToken != nil
    }

    func configure(developerToken: String?) {
        self.developerToken = developerToken
    }

    /// Placeholder: request a user token. In production, exchange developer token on a secure server.
    func requestUserToken() async throws -> String {
        if developerToken == nil {
            throw NSError(domain: "MusicKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Developer token not configured"]) 
        }
        // In a real app you would call MusicKit APIs here. Return a fake token for now.
        let fake = "FAKE_USER_TOKEN"
        self.userToken = fake
        return fake
    }

    func clear() {
        developerToken = nil
        userToken = nil
    }
}
