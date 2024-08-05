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
import UniformTypeIdentifiers

struct FavoritesView<Model: FavoritesModel>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isLandscapeOrientation) var isLandscape

    @ObservedObject var model: Model

    private let selectionFeedback = UISelectionFeedbackGenerator()

    var body: some View {
        VStack(alignment: .center, spacing: 24) {

            let columns = NewTabPageGrid.columnsCount(for: horizontalSizeClass, isLandscape: isLandscape)
            let result = model.prefixedFavorites(for: columns)

            NewTabPageGridView { _ in
                ReorderableForEach(result.items) { item in
                    Button(action: {
                        model.favoriteSelected(item)
                        selectionFeedback.selectionChanged()
                    }, label: {
                        FavoriteItemView(
                            favorite: item,
                            faviconLoading: model.faviconLoader,
                            onMenuAction: { action in
                                switch action {
                                case .delete: model.deleteFavorite(item)
                                case .edit: model.editFavorite(item)
                                }
                            })
                        .background(.clear)
                        .frame(width: NewTabPageGrid.Item.edgeSize)
                    })
                    .previewShape()
                } preview: { favorite in
                    FavoriteIconView(favorite: favorite, faviconLoading: model.faviconLoader)
                        .frame(width: NewTabPageGrid.Item.edgeSize)
                        .previewShape()
                } onMove: { from, to in
                    withAnimation {
                        model.moveFavorites(from: from, to: to)
                    }
                }
            }

            if result.isCollapsible {
                Button(action: {
                    withAnimation(.easeInOut) {
                        model.toggleCollapse()
                    }
                }, label: {
                    Image(model.isCollapsed ? .chevronDown : .chevronUp)
                        .resizable()
                })
                .buttonStyle(ToggleExpandButtonStyle())
            }
        }
    }
}

private extension View {
    func previewShape() -> some View {
        contentShape(.dragPreview, RoundedRectangle(cornerRadius: 8))
    }
}

extension Favorite: Reorderable {
    var dropItemProvider: NSItemProvider {
        NSItemProvider(object: (urlObject?.absoluteString ?? "") as NSString)
    }

    var dropType: UTType {
        .plainText
    }
}

#Preview {
    FavoritesView(model: FavoritesPreviewModel())
}
