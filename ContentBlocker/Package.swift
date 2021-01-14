// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ContentBlocker",
    products: [
        .library(
            name: "ContentBlocker",
            targets: ["ContentBlocker"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ContentBlocker",
            dependencies: []),
        .testTarget(
            name: "ContentBlockerTests",
            dependencies: ["ContentBlocker"])
    ]
)
