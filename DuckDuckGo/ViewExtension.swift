//
//  ViewExtension.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

extension View {
    /// Disables scroll if allowed by system version
    @ViewBuilder
    func withoutScroll(_ isScrollDisabled: Bool = true) -> some View {
        if #available(iOS 16, *) {
            scrollDisabled(isScrollDisabled)
        } else {
            self
        }
    }
}

extension View {
    /// Adds a preference key observer for views' frame in a given coordinate space.
    ///
    /// - Parameters:
    ///    - space: `CoordinateSpace` used to convert the frame to.
    ///    - key: `PreferenceKey` used to observe the value.
    ///    - perform: Closure to call on value change.
    func onFrameUpdate<K: PreferenceKey>(
        in space: CoordinateSpace,
        using key: K.Type,
        perform: @escaping (CGRect) -> Void) -> some View where K.Value == CGRect {

        self.background {
            GeometryReader(content: { geometry in
                Color.clear
                    .preference(key: key, value: geometry.frame(in: space))
            })
        }
        .onPreferenceChange(key, perform: perform)
    }
}

extension View {
    @ViewBuilder
    func applyInsetGroupedListStyle() -> some View {
        self
            .listStyle(.insetGrouped)
            .applyBackground()
    }

    @ViewBuilder
    func applyBackground() -> some View {
        hideScrollContentBackground()
        .background(
            Rectangle().ignoresSafeArea().foregroundColor(Color(designSystemColor: .background))
        )
    }

    @ViewBuilder
    func increaseHeaderProminence() -> some View {
        self.headerProminence(.increased)
    }

    @ViewBuilder
    private func hideScrollContentBackground() -> some View {
        if #available(iOS 16, *) {
            self.scrollContentBackground(.hidden)
        } else {
            let originalBackgroundColor = UITableView.appearance().backgroundColor
            self.onAppear {
                UITableView.appearance().backgroundColor = .clear
            }.onDisappear {
                UITableView.appearance().backgroundColor = originalBackgroundColor
            }
        }
    }
}
