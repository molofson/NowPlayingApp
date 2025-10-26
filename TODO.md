TODO for NowPlayingApp
======================

Short-term
----------
- [ ] Improve layout responsiveness: add scrollable panels when window is small.
- [ ] Fix Sendable closure warnings in `MusicStateModel` by avoiding non-sendable captures.
- [ ] Add unit tests for AppleScript parsing logic.

Medium-term
-----------
- [ ] Implement MusicKit integration for reliable metadata (requires developer account and entitlements).
- [ ] Add a proper Xcode project target and code signing for distribution.

Long-term / optional
--------------------
- [ ] Consider an AppKit-based menu bar interface for quick now-playing info.
- [ ] Explore Now Playing Info Center / system Now Playing APIs for richer integration (be mindful of private APIs).
