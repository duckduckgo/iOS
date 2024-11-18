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
import DuckUI

struct FavoritesView<Model: FavoritesViewModel>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isLandscapeOrientation) var isLandscape

    @ObservedObject var model: Model
    @Binding var isAddingFavorite: Bool
    let geometry: GeometryProxy?

    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let haptics = UIImpactFeedbackGenerator()

    var body: some View {
        VStack(alignment: .center, spacing: 24) {

            let columns = NewTabPageGrid.columnsCount(for: horizontalSizeClass,
                                                      isLandscape: isLandscape,
                                                      isDynamic: model.isNewTabPageCustomizationEnabled)
            let result = model.prefixedFavorites(for: columns)

            NewTabPageGridView(geometry: geometry, isUsingDynamicSpacing: model.isNewTabPageCustomizationEnabled) { _ in
                ReorderableForEach(result.items) { item in
                    viewFor(item)
                        .previewShape()
                        .transition(.opacity)
                } preview: { item in
                    previewFor(item)
                } onMove: { from, to in
                    haptics.impactOccurred()
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
                // Masks the content, which will otherwise shop up underneath while collapsing
                .background(Color(designSystemColor: .background))
            }
        }
        // Prevent the content to leak out of bounds while collapsing
        .clipped()
        .padding(0)
    }

    @ViewBuilder
    private func previewFor(_ item: FavoriteItem) -> some View {
        switch item {
        case .favorite(let favorite):
            FavoriteIconView(favorite: favorite, faviconLoading: model.faviconLoader)
                .frame(width: NewTabPageGrid.Item.edgeSize)
                .previewShape()
                .transition(.opacity)
        case .addFavorite, .placeholder:
            EmptyView()
        }
    }

    @ViewBuilder
    private func viewFor(_ item: FavoriteItem) -> some View {
        switch item {
        case .favorite(let favorite):
            Button(action: {
                model.favoriteSelected(favorite)
                selectionFeedback.selectionChanged()
            }, label: {
                FavoriteItemView(
                    favorite: favorite,
                    faviconLoading: model.faviconLoader,
                    onMenuAction: { action in
                        switch action {
                        case .delete: model.deleteFavorite(favorite)
                        case .edit: model.editFavorite(favorite)
                        }
                    })
                .background(.clear)
                .frame(width: NewTabPageGrid.Item.edgeSize)
            })
            .buttonStyle(.plain)
        case .addFavorite:
            Button(action: {
                isAddingFavorite = true
            }, label: {
                FavoriteAddItemView()
            })
            .buttonStyle(SecondaryFillButtonStyle(isFreeform: true))
            .frame(width: NewTabPageGrid.Item.edgeSize)
        case .placeholder:
            FavoritePlaceholderItemView()
                .frame(width: NewTabPageGrid.Item.edgeSize, height: NewTabPageGrid.Item.edgeSize)
                .contentShape(.rect)
                .onTapGesture {
                    model.placeholderTapped()
                }
        }
    }
}

private extension View {
    func previewShape() -> some View {
        contentShape(.dragPreview, RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    PreviewWrapperView()
}

private struct PreviewWrapperView: View {
    @State var isAddingFavorite = false
    var body: some View {
        FavoritesView(model: FavoritesPreviewModel(), isAddingFavorite: $isAddingFavorite, geometry: nil)
    }
}
