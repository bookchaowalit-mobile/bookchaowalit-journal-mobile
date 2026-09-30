// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MindSpace",
    // macOS is listed so `swift build` / `swift test` work on a Mac host (CI);
    // the UI only uses APIs available on both platforms.
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "MindSpaceCore", targets: ["MindSpaceCore"]),
    ],
    targets: [
        // Foundation-only domain logic (journal stats, meditation session).
        .target(name: "MindSpaceCore", path: "Sources/MindSpaceCore"),
        .executableTarget(
            name: "MindSpace",
            dependencies: ["MindSpaceCore"],
            path: "Sources/MindSpace"
        ),
        .testTarget(name: "MindSpaceCoreTests", dependencies: ["MindSpaceCore"], path: "Tests/MindSpaceCoreTests"),
    ]
)
