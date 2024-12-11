// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "AIChat",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AIChat",
            targets: ["AIChat"]
        ),
    ],
    targets: [
        .target(
            name: "AIChat",
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        ),
    ]
)
