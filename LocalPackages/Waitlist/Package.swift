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
    dependencies: [
        .package(url: "https://github.com/duckduckgo/BrowserServicesKit", exact: "111.0.0"),
        .package(url: "https://github.com/duckduckgo/DesignResourcesKit", exact: "2.0.0")
    ],
    targets: [
        .target(
            name: "Waitlist",
            dependencies: ["DesignResourcesKit"],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ],
            plugins: [.plugin(name: "SwiftLintPlugin", package: "BrowserServicesKit")]
        ),
        .target(
            name: "WaitlistMocks",
            dependencies: ["Waitlist"],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ],
            plugins: [.plugin(name: "SwiftLintPlugin", package: "BrowserServicesKit")]
        ),
        .testTarget(
            name: "WaitlistTests",
            dependencies: ["Waitlist", "WaitlistMocks"],
            plugins: [.plugin(name: "SwiftLintPlugin", package: "BrowserServicesKit")]
        )
    ]
)
