//
//  FavoriteIconView.swift
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

protocol FavoritesFaviconLoading {
    func loadFavicon(for favorite: Favorite, size: CGFloat) async -> Favicon?
    func fakeFavicon(for favorite: Favorite, size: CGFloat) -> Favicon

    func existingFavicon(for favorite: Favorite, size: CGFloat) -> Favicon?
}

struct FavoriteIconView: View {
    @State private var favicon: Favicon

    let favorite: Favorite
    let faviconLoading: FavoritesFaviconLoading?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(designSystemColor: .surface))
                .shadow(color: .shade(0.12), radius: 0.5, y: 1)
                .aspectRatio(1, contentMode: .fit)

            Image(uiImage: favicon.image)
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
                .if(favicon.isUsingBorder) {
                    $0.padding(Constant.borderSize)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .task {
            if favicon.isFake, let favicon = await faviconLoading?.loadFavicon(for: favorite, size: Constant.faviconSize) {
                self.favicon = favicon
            }
        }
    }
}

private struct Constant {
    static let faviconSize: CGFloat = 64
    static let borderSize: CGFloat = 12
}

#Preview {
    VStack(spacing: 8) {
        FavoriteIconView(favorite: Favorite.mock("apple.com"), faviconLoading: nil)
        FavoriteIconView(favorite: Favorite.mock("duckduckgo.com"), faviconLoading: nil)
        FavoriteIconView(favorite: Favorite.mock("foobar.com"), faviconLoading: nil)
    }
}

private extension Favorite {
    static func mock(_ domain: String) -> Favorite {
        return Favorite(id: domain, title: domain, domain: domain)
    }
}

extension FavoriteIconView {
    init(favorite: Favorite, faviconLoading: FavoritesFaviconLoading? = nil) {
        let favicon = faviconLoading?.existingFavicon(for: favorite, size: Constant.faviconSize)
        ?? faviconLoading?.fakeFavicon(for: favorite, size: Constant.faviconSize)
        ?? .empty
        self.init(favicon: favicon, favorite: favorite, faviconLoading: faviconLoading)
    }
}
