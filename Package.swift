// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "NowPlayingApp",
    platforms: [.macOS("14.0")],
    products: [
        .executable(name: "NowPlayingApp", targets: ["NowPlayingApp"]),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "NowPlayingApp",
            dependencies: [],
            path: "Sources/NowPlayingApp"
        )
    ]
)
