// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Waitlist",
    platforms: [
        .iOS(.v14)
    ],

    products: [
        .library(
            name: "Waitlist",
            targets: ["Waitlist"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Waitlist",
            dependencies: []),
        .testTarget(
            name: "WaitlistTests",
            dependencies: ["Waitlist"])
    ]
)
