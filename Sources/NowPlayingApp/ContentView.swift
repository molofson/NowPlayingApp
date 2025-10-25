import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: MusicStateModel

    var body: some View {
        VStack(spacing: 12) {
            Text(model.playerStateTitle)
                .font(.title2)
                .bold()
            Text(model.trackInfo)
                .font(.body)
                .multilineTextAlignment(.center)
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
