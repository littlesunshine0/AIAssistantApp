// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AIAssistantKit",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "AIAssistantKit",
            targets: ["AIAssistantKit"]
        )
    ],
    targets: [
        .target(
            name: "AIAssistantKit",
            dependencies: [],
            path: "Sources/AIAssistantKit"
        )
    ]
)
