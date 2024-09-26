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
    func loadFavicon(for domain: String, size: CGFloat) async -> Favicon?
    func fakeFavicon(for domain: String, size: CGFloat) -> Favicon

    func existingFavicon(for domain: String, size: CGFloat) -> Favicon?
}

struct FavoriteIconView: View {
    @State var favicon: Favicon

    @State var size: CGFloat = Constant.faviconSize
    let domain: String
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
            if favicon.isFake, let favicon = await faviconLoading?.loadFavicon(for: domain, size: Constant.faviconSize) {
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
        FavoriteIconView(domain: "apple.com", faviconLoading: nil)
        FavoriteIconView(domain: "duckduckgo.com", faviconLoading: nil)
        FavoriteIconView(domain: "foobar.com", faviconLoading: nil)
    }
}

private extension Favorite {
    static func mock(_ domain: String) -> Favorite {
        return Favorite(id: domain, title: domain, domain: domain)
    }
}

extension FavoriteIconView {
    init(domain: String, size: CGFloat? = nil, faviconLoading: FavoritesFaviconLoading? = nil) {
        let size = size ?? Constant.faviconSize
        let favicon = faviconLoading?.existingFavicon(for: domain, size: size)
        ?? faviconLoading?.fakeFavicon(for: domain, size: size)
        ?? .empty

        self.init(favicon: favicon, size: size, domain: domain, faviconLoading: faviconLoading)
    }

    init(favorite: Favorite, size: CGFloat? = nil, faviconLoading: FavoritesFaviconLoading? = nil) {
        self.init(domain: favorite.domain, size: size, faviconLoading: faviconLoading)
    }

    init(favicon: Favicon) {
        self.init(favicon: favicon, domain: "", faviconLoading: nil)
    }
}
