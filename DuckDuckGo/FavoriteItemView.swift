//
//  FavoriteItemView.swift
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

import DesignResourcesKit
import SwiftUI

struct FavoriteItemView: View {
    let favorite: Favorite
    let faviconLoading: FavoritesFaviconLoading?
    let onMenuAction: ((MenuAction) -> Void)?

    var body: some View {
        VStack(spacing: 6) {
            FavoriteIconView(favorite: favorite, faviconLoading: faviconLoading)
            .contextMenu {
                // This context menu can be moved up in the hierarchy to `FavoritesView` once support for iOS 15 is removed. contextMenu with preview modifier can be used then.
                    contextMenuItems()
            }

            Text(favorite.title)
                .font(Font.system(size: 12))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(designSystemColor: .textPrimary))
                .frame(maxWidth: .infinity, alignment: .top)
        }
        .accessibilityElement()
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("\(favorite.title). \(UserText.favorite)")
    }

    private func contextMenuItems() -> some View {
        Section(favorite.menuTitle) {
            Button {
                onMenuAction?(.edit)
            } label: {
                Label(UserText.favoriteMenuEdit, image: "Edit")
            }

            Button {
                onMenuAction?(.delete)
            } label: {
                Label(UserText.favoriteMenuRemove, image: "RemoveFavoriteMenuIcon")
            }
        }
    }
}

extension FavoriteItemView {
    enum MenuAction {
        case edit
        case delete
    }
}

#Preview {
    HStack(alignment: .top) {
        FavoriteItemView(favorite: Favorite(id: UUID().uuidString, title: "Text", domain: "facebook.com")).frame(width: 64)
        FavoriteItemView(favorite: Favorite(id: UUID().uuidString, title: "Lorem Ipsum is simply dummy text of the printing and typesetting industry", domain: "duckduckgo.com")).frame(width: 64)
    }
}

private extension FavoriteItemView {
    init(favorite: Favorite) {
        self.init(favorite: favorite, faviconLoading: nil, onMenuAction: nil)
    }
}
