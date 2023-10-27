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

/*
 These exensions are needed to provide the UI styling specs for Network Protection
 However, at time of writing, they are not supported in iOS <=14. As Network Protection
 is not supporting iOS <=14, these are being kept separate.
 */

@available(iOS 15, *)
extension View {
    @ViewBuilder
    func applyInsetGroupedListStyle() -> some View {
        self
            .listStyle(.insetGrouped)
            .hideScrollContentBackground()
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
