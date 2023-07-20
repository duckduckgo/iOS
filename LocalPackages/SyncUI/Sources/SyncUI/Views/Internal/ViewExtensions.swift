//
//  ViewExtensions.swift
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

/// These extension are a sort of poly-fill for functionality not available in iOS 14/15
extension View {

    @ViewBuilder
    func hideScrollContentBackground() -> some View {
        if #available(iOS 16, *) {
            self.scrollContentBackground(.hidden)
        } else {
            self
        }
    }

    @ViewBuilder
    func disableScrolling() -> some View {
        if #available(iOS 16, *) {
            self.scrollDisabled(true)
        } else {
            self
        }
    }

    @ViewBuilder
    func regularMaterialBackground() -> some View {
        if #available(iOS 15.0, *) {
            self.background(.regularMaterial)
        } else {
            self.background(Rectangle().foregroundColor(.black.opacity(0.9)))
        }
    }

    @ViewBuilder
    func thinMaterialBackground() -> some View {
        if #available(iOS 15.0, *) {
            self.background(.ultraThinMaterial)
        } else {
            self.background(Rectangle().foregroundColor(.black.opacity(0.9)))
        }
    }

    @ViewBuilder
    func monospaceSystemFont(ofSize size: Double) -> some View {
        if #available(iOS 15.0, *) {
            font(.system(size: size).monospaced())
        } else {
            font(.system(size: size))
        }
    }

    @ViewBuilder
    func applyKerning(_ kerning: CGFloat) -> some View {
        if #available(iOS 16.0, *) {
            self.kerning(kerning)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyListStyle() -> some View {
        self
            .listStyle(.insetGrouped)
            .listStyle(.insetGrouped)
            .hideScrollContentBackground()
            .background(
                Rectangle().ignoresSafeArea().foregroundColor(Color.syncBackground))
    }

    @ViewBuilder
    func applyViewModifier(_ modifier: some ViewModifier, if condition: Bool) -> some View {
        if condition {
            self.modifier(modifier)
        } else {
            self
        }
    }

}

private extension Color {
    static let syncBackground = Color("SyncBackgroundColor")
}
