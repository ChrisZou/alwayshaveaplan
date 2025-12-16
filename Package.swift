// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AlwaysHaveAPlan",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(name: "AlwaysHaveAPlan", targets: ["AlwaysHaveAPlanApp"]),
    ],
    targets: [
        .executableTarget(
            name: "AlwaysHaveAPlanApp",
            path: "Sources/App",
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)

