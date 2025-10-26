NowPlayingApp
===============

Minimal macOS SwiftUI-based diagnostic app that shows Apple Music playing state and several diagnostics.

Quick start
-----------

- Build and run with Swift Package Manager:

```bash
swift build
swift run
```

What it shows
-------------
- Current player state via AppleScript (playing/not playing)
- Track attributes AppleScript exposes (title, artist, position, duration)
- Private API detection (presence of common private media frameworks)
- MediaPlayer availability (MPNowPlayingInfoCenter class presence)

Persistence
-----------
- The app saves the window frame to `UserDefaults` so the size/position is remembered between runs.

Next steps
----------
See `TODO.md` for planned improvements and migration to MusicKit.
