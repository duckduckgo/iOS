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
        .package(url: "https://github.com/duckduckgo/DesignResourcesKit", exact: "2.0.0"),
        .package(url: "https://github.com/duckduckgo/apple-toolbox.git", exact: "2.0.0"),
    ],
    targets: [
        .target(
            name: "Waitlist",
            dependencies: [
                "DesignResourcesKit",
                .product(name: "Macros", package: "apple-toolbox"),
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ],
            plugins: [.plugin(name: "SwiftLintPlugin", package: "apple-toolbox")]
        ),
        .target(
            name: "WaitlistMocks",
            dependencies: ["Waitlist"],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ],
            plugins: [.plugin(name: "SwiftLintPlugin", package: "apple-toolbox")]
        ),
        .testTarget(
            name: "WaitlistTests",
            dependencies: ["Waitlist", "WaitlistMocks"],
            plugins: [.plugin(name: "SwiftLintPlugin", package: "apple-toolbox")]
        )
    ]
)
