// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Subscription",
    platforms: [ .macOS(.v11), .iOS(.v15) ],
    products: [
        .library(
            name: "Subscription",
            targets: ["Subscription"]),
    ],
    dependencies: [
        .package(path: "../Account"),
        .package(path: "../Purchase"),
    ],
    targets: [
        .target(
            name: "Subscription",
            dependencies: [
                .product(name: "Account", package: "Account"),
                .product(name: "Purchase", package: "Purchase"),
            ]),
        .testTarget(
            name: "SubscriptionTests",
            dependencies: ["Subscription"]),
    ]
)
