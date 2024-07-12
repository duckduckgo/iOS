//
//  FavoritesView.swift
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

import Bookmarks
import SwiftUI

struct FavoritesView<Model: FavoritesModel>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isLandscapeOrientation) var isLandscape

    @ObservedObject var model: Model

    @State private var isCollapsed = true

    private let selectionFeedback = UISelectionFeedbackGenerator()

    var body: some View {
        VStack(alignment: .center, spacing: 24) {

            let collapsedMaxItemsCount = NewTabPageGrid.columnsCount(for: horizontalSizeClass, isLandscape: isLandscape) * 2

            let data = isCollapsed ? Array(model.allFavorites.prefix(collapsedMaxItemsCount)) : model.allFavorites
            
            NewTabPageGridView { _ in
                ForEach(data) { item in
                    Button(action: {
                        model.favoriteSelected(item)
                        selectionFeedback.selectionChanged()
                    }, label: {
                        FavoriteItemView(favorite: item, onFaviconMissing: {
                            self.model.faviconMissing()
                        })
                        .frame(width: NewTabPageGrid.Item.edgeSize)
                    })
                }
            }

            if model.allFavorites.count > collapsedMaxItemsCount {
                Button(action: {
                    isCollapsed.toggle()
                }, label: {
                }).buttonStyle(ToggleExpandButtonStyle(direction: isCollapsed ? .down : .up))
            }
        }
    }
}

#Preview {
    FavoritesView(model: FavoritesPreviewModel())
}
