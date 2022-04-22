// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "DuckUI",
    platforms: [
        .iOS(.v13)
    ],
    
    products: [
        .library(
            name: "DuckUI",
            targets: ["DuckUI"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DuckUI",
            dependencies: [])
    ]
)
