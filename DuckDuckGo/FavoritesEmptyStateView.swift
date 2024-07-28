//
//  FavoritesEmptyStateView.swift
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

import SwiftUI

struct FavoritesEmptyStateView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isLandscapeOrientation) var isLandscape

    @State private var headerPadding: CGFloat = 10

    @Binding var isShowingTooltip: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 16) {
                FavoritesSectionHeader(isShowingTooltip: $isShowingTooltip)
                    .padding(.horizontal, headerPadding)

                NewTabPageGridView { placeholdersCount in
                    let placeholders = Array(0..<placeholdersCount)
                    ForEach(placeholders, id: \.self) { _ in
                        FavoriteEmptyStateItem()
                            .frame(width: NewTabPageGrid.Item.edgeSize, height: NewTabPageGrid.Item.edgeSize)
                    }
                }.overlay(
                    GeometryReader(content: { geometry in
                        Color.clear.preference(key: WidthKey.self, value: geometry.frame(in: .local).width)
                    })
                )
                .onPreferenceChange(WidthKey.self, perform: { fullWidth in
                    let columnsCount = Double(NewTabPageGrid.columnsCount(for: horizontalSizeClass, isLandscape: isLandscape))
                    let allColumnsWidth = columnsCount * NewTabPageGrid.Item.edgeSize
                    let leftoverWidth = fullWidth - allColumnsWidth
                    let spacingSize = leftoverWidth / (columnsCount)
                    self.headerPadding = spacingSize / 2
                })
            }

            if isShowingTooltip {
                FavoritesTooltip()
                    .offset(x: -headerPadding + 18, y: 24)
                    .frame(maxWidth: .infinity, alignment: .bottomTrailing)
            }
        }
    }
}

#Preview {
    @State var isShowingTooltip = false
    return FavoritesEmptyStateView(isShowingTooltip: $isShowingTooltip)
}

private struct WidthKey: PreferenceKey {
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
    static var defaultValue: CGFloat = .zero
}
