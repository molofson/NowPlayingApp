import SwiftUI

@main
struct NowPlayingAppMain: App {
    @StateObject private var model = MusicStateModel()

    var body: some Scene {
        WindowGroup("Now Playing") {
            ContentView()
                .environmentObject(model)
                .frame(minWidth: 300, minHeight: 120)
                .onAppear {
                    model.startPolling()
                }
        }
    }
}
