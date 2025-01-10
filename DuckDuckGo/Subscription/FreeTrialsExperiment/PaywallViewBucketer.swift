//
//  PaywallViewBucketer.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import Foundation

/// A protocol for defining a bucketing system.
/// - Note: The value to bucket is now explicitly an `Int`, removing the need for an associated type.
protocol Bucketer {
    /// Determines the bucket for the given value.
    /// - Parameter value: The integer value to bucket.
    /// - Returns: A string label representing the bucket the value belongs to.
    func bucket(for value: Int) -> String
}

/// An implementation of the `Bucketer` protocol for bucketing paywall view counts.
struct PaywallViewBucketer: Bucketer {
    /// A list of bucket ranges and their corresponding labels.
    private let buckets: [(range: ClosedRange<Int>, label: String)] = [
        (1...1, "1"),
        (2...2, "2"),
        (3...3, "3"),
        (4...4, "4"),
        (5...5, "5"),
        (6...10, "6-10"),
        (11...50, "11-50"),
        (51...Int.max, "51+")
    ]

    /// Finds the bucket label for a given value.
    /// - Parameter value: The number of paywall views.
    /// - Returns: A string label representing the bucket, or "Unknown" if no bucket matches.
    func bucket(for value: Int) -> String {
        for bucket in buckets where bucket.range.contains(value) {
            return bucket.label
        }
        return "Unknown"
    }
}
