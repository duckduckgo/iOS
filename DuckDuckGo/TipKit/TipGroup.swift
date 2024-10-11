//
//  TipGroup.swift
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
import TipKit

/// Backport of TipKit's TipGroup to iOS versions lower than iOS 18.
///
/// In iOS 17: this class should provide the same functionality as TipKit's `TipGroup`.
/// Before iOS 17: this class should be a glorified no-op that compiles correctly.
///
@available(iOS, obsoleted: 18.0, renamed: "LegacyTipGroup")
struct TipGroup {

    public enum Priority: Sendable {

        /// Shows the first tip eligible for display.
        case firstAvailable

        /// Shows an eligible tip when all of the previous tips have been [`invalidated`](doc:Tips/Status/invalidated(_:)).
        case ordered
    }

    private let priority: Priority
    private let tips: [Any]

    /// Initializers for iOS versions below 17.0
    ///
    @available(iOS, obsoleted: 17.0)
    public init(_ priority: Priority = .firstAvailable, @LegacyTipGroupBuilder _ builder: () -> [Any]) {

        self.priority = priority
        self.tips = builder()
    }

    /// Initializers for iOS 17.0
    ///
    @available(iOS 17.0, *)
    public init(_ priority: Priority = .firstAvailable, @LegacyTipGroupBuilder _ builder: () -> [any Tip]) {

        self.priority = priority
        self.tips = builder()
    }

    @available(iOS 17.0, *)
    @MainActor
    var currentTip: (any Tip)? {
        guard let tips = tips as? [any Tip] else {
            return nil
        }

        return tips.first {
            switch $0.status {
            case .available:
                return true
            case .invalidated:
                return false
            case .pending:
                return priority == .ordered
            @unknown default:
                // Since this code is limited to iOS 17 and deprecated in iOS 18, we shouldn't
                // need to worry about unknown cases.
                fatalError("This path should never be called")
            }
        }
    }
}

@available(iOS, obsoleted: 18.0)
@resultBuilder public struct LegacyTipGroupBuilder {
    public static func buildBlock() -> [Any] {
        []
    }

    public static func buildBlock(_ components: Any...) -> [Any] {
        components
    }

    public static func buildPartialBlock(first: Any) -> [Any] {
        [first]
    }

    public static func buildPartialBlock(first: [Any]) -> [Any] {
        first
    }

    public static func buildPartialBlock(accumulated: [Any], next: Any) -> [Any] {
        accumulated + [next]
    }

    public static func buildPartialBlock(accumulated: [Any], next: [Any]) -> [Any] {

        accumulated + next
    }

    public static func buildPartialBlock(first: Void) -> [Any] {
        []
    }

    public static func buildPartialBlock(first: Never) -> [Any] {
        // This will never be called
    }

    public static func buildIf(_ element: [Any]?) -> [Any] {
        element ?? []
    }

    public static func buildEither(first: [Any]) -> [Any] {
        first
    }

    public static func buildEither(second: [Any]) -> [Any] {
        second
    }

    public static func buildArray(_ components: [[Any]]) -> [Any] {
        components.flatMap { $0 }
    }
}
