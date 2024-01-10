// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Subscription",
    platforms: [ .macOS(.v11), .iOS(.v14) ],
    products: [
        .library(
            name: "Subscription",
            targets: ["Subscription"]),
    ],
    dependencies: [
        .package(url: "https://github.com/duckduckgo/BrowserServicesKit", exact: "94.0.0"),
    ],
    targets: [
        .target(
            name: "Subscription",
            dependencies: [
                .product(name: "BrowserServicesKit", package: "BrowserServicesKit"),
            ]),
        .testTarget(
            name: "SubscriptionTests",
            dependencies: ["Subscription"]),
    ]
)
