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

import Common
import DesignResourcesKit
import DuckUI
import SwiftUI

struct FavoritesView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var model: FavoritesModel

    @State var isCollapsed: Bool = true

    var body: some View {
        VStack(alignment: .center) {
            
            let collapsedMaxItemsCount = NewTabPageGrid.columnsCount(for: horizontalSizeClass) * 2

            if model.isEmpty {
                FavoritesSectionHeader()
                NewTabPageGridView { columnsCount in
                    let range = (0..<columnsCount).map { $0 }
                    ForEach(range, id: \.self) { _ in
                        FavoriteEmptyStateItem()
                            .frame(width: NewTabPageGrid.Item.edgeSize,
                                   height: NewTabPageGrid.Item.edgeSize)
                    }
                }
            } else {
                let data = isCollapsed ? Array(model.allFavorites.prefix(collapsedMaxItemsCount)) : model.allFavorites

                NewTabPageGridView { _ in
                    ForEach(data) { item in
                        FavoriteItemView(favicon: emptyIcon(), name: "\(item.id)")
                            .frame(width: NewTabPageGrid.Item.edgeSize)
                    }
                }
            }

            if model.allFavorites.count > collapsedMaxItemsCount {
                Button(action: {
                    isCollapsed.toggle()
                }, label: {
                    ToggleExpandButtonView(isIndicatingExpand: isCollapsed).padding()
                })
            }
        }
        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
    }
    
    private func emptyIcon() -> Image {
        Image(systemName: "square.grid.3x3.middle.filled")
    }
}

#Preview {
    FavoritesView(model: FavoritesModel())
}
