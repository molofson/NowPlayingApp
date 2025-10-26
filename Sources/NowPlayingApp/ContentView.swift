import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: MusicStateModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(model.playerStateTitle)
                    .font(.title2)
                    .bold()
                Spacer()
                Text(model.trackTimeDisplay)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(model.trackInfo)
                .font(.body)
                .multilineTextAlignment(.center)

            Divider()

            // Panels
            VStack(spacing: 12) {
                // AppleScript panel
                VStack(alignment: .leading, spacing: 6) {
                    HStack { Text("AppleScript").font(.headline); Spacer(); Button("Refresh") { Task { await model.runAppleScriptDiagnostic() } } }
                    Text("State: \(model.appleScriptState)")
                        .font(.caption)
                    Text("Title: \(model.appleScriptTitle)")
                        .font(.caption)
                    Text("Artist: \(model.appleScriptArtist)")
                        .font(.caption)
                    Text("Position / Duration: \(model.appleScriptPosition) / \(model.appleScriptDuration)")
                        .font(.caption)
                    Text(model.appleScriptDiag)
                        .font(.caption2)
                        .lineLimit(3)
                }

                Divider()

                // Private APIs panel
                VStack(alignment: .leading, spacing: 6) {
                    HStack { Text("Private APIs").font(.headline); Spacer(); Button("Refresh") { Task { await model.runPrivateAPIDiagnostic() } } }
                    Text(model.privateAPIDiag)
                        .font(.caption2)
                        .lineLimit(8)
                }

                Divider()

                // MusicKit panel
                VStack(alignment: .leading, spacing: 6) {
                    HStack { Text("MusicKit").font(.headline); Spacer(); Button("Refresh") { model.runMusicKitDiagnostic() } }
                    Text(model.musicKitDiag)
                        .font(.caption)
                }

                Divider()

                // MediaPlayer panel
                VStack(alignment: .leading, spacing: 6) {
                    HStack { Text("MediaPlayer").font(.headline); Spacer(); Button("Refresh") { model.runMediaPlayerDiagnostic() } }
                    Text(model.mediaPlayerDiag)
                        .font(.caption)
                }

                HStack {
                    Button("Refresh All") {
                        model.startDiagnosticsABThenD()
                    }
                    Spacer()
                }
            }
        }
        .padding()
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MusicStateModel())
    }
}
#endif
