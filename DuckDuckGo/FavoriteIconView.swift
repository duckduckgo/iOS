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
import Core

struct FavoriteIconView: View {
    let domain: String

    @MainActor
    @State private var favicon: Favicon

    @MainActor
    init(domain: String) {
        self.domain = domain
        self.favicon = Self.createFakeFavicon(for: domain)
    }

    var body: some View {
        favicon.image
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
            .if(favicon.isUsingBorder) {
                $0.padding(Constants.borderSize)
            }
            .task {
                if let favicon = await loadFavicon() {
                    self.favicon = favicon
                }
            }
    }

    private func loadFavicon() async -> Favicon? {
        await withCheckedContinuation { continuation in
            FaviconsHelper.loadFaviconSync(forDomain: domain,
                                           usingCache: .fireproof,
                                           useFakeFavicon: false) { icon, _ in
                guard let icon else {
                    continuation.resume(returning: .none)
                    return
                }

                let useBorder = URL.isDuckDuckGo(domain: domain) || icon.size.width < Constants.faviconSize
                let image = Image(uiImage: icon)
                continuation.resume(returning: Favicon(image: image, isUsingBorder: useBorder))
            }
        }
    }

    static private func createFakeFavicon(for domain: String) -> Favicon {
        let color = UIColor.forDomain(domain)
        let icon = FaviconsHelper.createFakeFavicon(
            forDomain: domain,
            size: Constants.faviconSize,
            backgroundColor: color,
            bold: false
        ) ?? UIImage()

        return Favicon(image: Image(uiImage: icon), isUsingBorder: false)
    }

    struct Constants {
        static let faviconSize: CGFloat = 40
        static let borderSize: CGFloat = 12
    }
}

private struct Favicon {
    let image: Image
    let isUsingBorder: Bool
}
