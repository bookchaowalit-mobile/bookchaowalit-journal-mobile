// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MindSpace",
    platforms: [.iOS(.v17)],
    targets: [
        .executableTarget(
            name: "MindSpace",
            path: "Sources/MindSpace"
        ),
    ]
)
