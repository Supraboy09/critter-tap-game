// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "critter-tap-game",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .executable(name: "critter-tap-game", targets: ["CritterTapGame"])
    ],
    targets: [
        .executableTarget(
            name: "CritterTapGame",
            path: "Sources/CritterTapGame"
        ),
        .testTarget(
            name: "CritterTapGameTests",
            path: "Tests/CritterTapGameTests"
        )
    ]
)
