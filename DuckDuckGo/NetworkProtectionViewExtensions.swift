//
//  NetworkProtectionViewExtensions.swift
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

/*
 These exensions are needed to provide the UI styling specs for Network Protection
 However, at time of writing, they are not supported in iOS <=14. As Network Protection
 is not supporting iOS <=14, these are being kept separate.
 */

extension View {
    @ViewBuilder
    func applyInsetGroupedListStyleForiOS15AndOver() -> some View {
        self
            .listStyle(.insetGrouped)
            .hideScrollContentBackground()
            .background(
                Rectangle().ignoresSafeArea().foregroundColor(Color(designSystemColor: .background))
            )
    }

    @ViewBuilder
    func increaseHeaderProminenceForiOS15AndOver() -> some View {
        if #available(iOS 15, *) {
            self.headerProminence(.increased)
        } else {
            self
        }
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
