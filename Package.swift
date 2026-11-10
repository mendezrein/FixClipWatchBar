// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FixClipWatchBar",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "FixClipWatchBar",
            path: "Sources"
        )
    ]
)