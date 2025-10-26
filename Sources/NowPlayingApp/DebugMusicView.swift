import SwiftUI

#if DEBUG
struct DebugMusicView: View {
    @State private var devToken: String = KeychainHelper.shared.string(forKey: "nowplaying.developerToken") ?? ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Debug: MusicKit Developer Token").font(.headline)
            TextField("Developer Token", text: $devToken)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            HStack {
                Button("Save") {
                    MusicKitManager.shared.configure(developerToken: devToken.isEmpty ? nil : devToken)
                }
                Button("Clear") {
                    devToken = ""
                    MusicKitManager.shared.clear()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

struct DebugMusicView_Previews: PreviewProvider {
    static var previews: some View {
        DebugMusicView()
    }
}
#endif
