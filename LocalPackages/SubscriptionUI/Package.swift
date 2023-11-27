// swift-tools-version:5.7
//  Package.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import PackageDescription

let package = Package(
    name: "SubscriptionUI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SubscriptionUI",
            targets: ["SubscriptionUI"])
    ],
    dependencies: [
        .package(path: "../Account"),
        .package(path: "../Purchase"),
        .package(path: "../DuckUI"),
        .package(url: "https://github.com/duckduckgo/DesignResourcesKit", exact: "2.0.0")
    ],
    targets: [
        .target(
            name: "SubscriptionUI",
            dependencies: [
                .product(name: "Account", package: "Account"),
                .product(name: "Purchase", package: "Purchase"),
                .product(name: "DuckUI", package: "DuckUI"),
                "DesignResourcesKit"
            ])
    ]
)
