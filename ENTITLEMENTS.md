MusicKit entitlements and setup

1) Developer account & MusicKit
- You must have an Apple Developer account. MusicKit and related entitlements are controlled in the Apple Developer portal.

2) Entitlements to request
- com.apple.developer.musickit — MusicKit entitlement. Request in App ID capabilities.
- If sandboxing macOS app: enable App Sandbox and configure networking if your app fetches tokens.

3) Developer token
- Generate a developer token on your server using your MusicKit private key. Do not embed private keys in the app.
- Create a server endpoint that exchanges Apple Music credentials and issues short-lived user tokens.

4) Client flow
- App contacts your server to get a developer token or user token flow; server exchanges credentials with Apple and returns a token.
- App uses MusicKit APIs with the returned token.

5) Local testing
- You can test the scaffolding in this repo which returns a fake user token when `MusicKitManager.configure(developerToken:)` is set.
