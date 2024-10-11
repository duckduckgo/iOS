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

protocol TipGrouping {
    @available(iOS 17.0, *)
    @MainActor
    var currentTip: (any Tip)? { get }
}

// This only compiles in Xcode 16 and needs to be re-enalbed once we move to it.
//
//@available(iOS 18.0, *)
//extension TipGroup: TipGrouping {}

/// A glorified no-op to be able to compile TipGrouping in iOS versions below 17.
///
struct EmptyTipGroup: TipGrouping {
    @available(iOS 17.0, *)
    var currentTip: (any Tip)? {
        return nil
    }
}

/// Backport of TipKit's TipGroup to iOS 17.
///
/// In iOS 17: this class should provide the same functionality as TipKit's `TipGroup`.
///
@available(iOS 17.0, *)
@available(iOS, obsoleted: 18.0)
struct LegacyTipGroup: TipGrouping {

    /// This is an implementation of TipGroup.Priority for iOS versions below 18.
    ///
    enum Priority {

        /// Shows the first tip eligible for display.
        case firstAvailable

        /// Shows an eligible tip when all of the previous tips have been [`invalidated`](doc:Tips/Status/invalidated(_:)).
        case ordered
    }

    private let priority: Priority
    private let tips: [any Tip]

    init(_ priority: Priority, @LegacyTipGroupBuilder _ builder: () -> [any Tip]) {
        self.priority = priority
        self.tips = builder()
    }

    @MainActor
    var currentTip: (any Tip)? {
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

    @MainActor
    var current: Any? {
        currentTip
    }
}

@available(iOS 17.0, *)
@available(iOS, obsoleted: 18.0)
@resultBuilder public struct LegacyTipGroupBuilder {
    public static func buildBlock() -> [Any] {
        []
    }

    public static func buildBlock(_ components: any Tip...) -> [any Tip] {
        components
    }

    public static func buildPartialBlock(first: any Tip) -> [any Tip] {
        [first]
    }

    public static func buildPartialBlock(first: [any Tip]) -> [any Tip] {
        first
    }

    public static func buildPartialBlock(accumulated: [any Tip], next: any Tip) -> [any Tip] {
        accumulated + [next]
    }

    public static func buildPartialBlock(accumulated: [any Tip], next: [any Tip]) -> [any Tip] {

        accumulated + next
    }

    public static func buildPartialBlock(first: Void) -> [any Tip] {
        []
    }

    public static func buildPartialBlock(first: Never) -> [any Tip] {
        // This will never be called
    }

    public static func buildIf(_ element: [any Tip]?) -> [any Tip] {
        element ?? []
    }

    public static func buildEither(first: [any Tip]) -> [any Tip] {
        first
    }

    public static func buildEither(second: [any Tip]) -> [any Tip] {
        second
    }

    public static func buildArray(_ components: [[any Tip]]) -> [any Tip] {
        components.flatMap { $0 }
    }
}
