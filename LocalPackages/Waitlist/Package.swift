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
            targets: ["Waitlist", "WaitlistMocks"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Waitlist",
            dependencies: []),
        .target(
            name: "WaitlistMocks",
            dependencies: ["Waitlist"]),
        .testTarget(
            name: "WaitlistTests",
            dependencies: ["Waitlist", "WaitlistMocks"])
    ]
)
