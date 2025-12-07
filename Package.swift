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
        .target(
            name: "CritterTapGame",
            path: "Sources/CritterTapGame",
            resources: [
                .process("../Resources")
            ]
        ),
        .testTarget(
            name: "CritterTapGameTests",
            path: "Tests"
        )
    ]
)
