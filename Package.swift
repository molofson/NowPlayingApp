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
            path: "Sources/NowPlayingApp",
            swiftSettings: [
                // Treat warnings as errors to enforce clean builds
                .unsafeFlags(["-warnings-as-errors"], .when(configuration: .debug)),
                .unsafeFlags(["-warnings-as-errors"], .when(configuration: .release))
            ]
        )
        , .testTarget(
            name: "NowPlayingAppTests",
            dependencies: ["NowPlayingApp"],
            path: "Tests/NowPlayingAppTests"
        )
    ]
)
