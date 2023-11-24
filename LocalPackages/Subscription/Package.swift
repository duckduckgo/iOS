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
        //.package(path: "../SwiftUIExtensions")
    ],
    targets: [
        .target(
            name: "Subscription",
            dependencies: [
                .product(name: "Account", package: "Account"),
                .product(name: "Purchase", package: "Purchase"),
                //.product(name: "SwiftUIExtensions", package: "SwiftUIExtensions")
            ],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "SubscriptionTests",
            dependencies: ["Subscription"]),
    ]
)
