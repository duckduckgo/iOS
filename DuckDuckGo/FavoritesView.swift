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
import Core

struct FavoritesView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var model: FavoritesModel
    
    @State var isCollapsed: Bool = true

    var body: some View {
        VStack(alignment: .center) {

            let collapsedMaxItemsCount = NewTabPageGrid.columnsCount(for: horizontalSizeClass) * 2
            
            let data = isCollapsed ? Array(model.allFavorites.prefix(collapsedMaxItemsCount)) : model.allFavorites
            
            NewTabPageGridView { _ in
                ForEach(data) { item in
                    FavoriteItemView(favorite: item)
                    .frame(width: NewTabPageGrid.Item.edgeSize)
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
    }
}

#Preview {
    FavoritesView(model: FavoritesModel())
}

extension FavoritesModel {
    convenience init() {
        let location = FileManager.default.temporaryDirectory.appendingPathComponent("Bookmarks.sqlite", conformingTo: .database)
        let db = BookmarksDatabase.make(location: location)
        db.loadStore()

        self.init(interactionModel: FavoritesListViewModel(bookmarksDatabase: db, favoritesDisplayMode: .default))
    }
}
