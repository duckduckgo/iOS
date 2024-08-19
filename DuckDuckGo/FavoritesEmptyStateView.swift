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

struct FavoritesEmptyStateView<Model: FavoritesEmptyStateModel>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isLandscapeOrientation) var isLandscape

    @ObservedObject var model: Model

    @State private var headerPadding: CGFloat = 10

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 16) {
                FavoritesSectionHeader(model: model)
                    .padding(.horizontal, headerPadding)

                NewTabPageGridView { placeholdersCount in
                    let placeholders = Array(0..<placeholdersCount)
                    ForEach(placeholders, id: \.self) { _ in
                        FavoriteEmptyStateItem()
                            .frame(width: NewTabPageGrid.Item.edgeSize, height: NewTabPageGrid.Item.edgeSize)
                            .contentShape(.capsule)
                            .onTapGesture {
                                model.placeholderTapped()
                            }
                    }
                }
            }

            if model.isShowingTooltip {
                FavoritesTooltip()
                    .offset(x: 18, y: 24)
                    .frame(maxWidth: .infinity, alignment: .bottomTrailing)
            }
        }
    }
}

#Preview {
    return FavoritesEmptyStateView(model: FavoritesPreviewModel())
}
