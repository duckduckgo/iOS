//
//  FavoriteIconViewModel.swift
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

final class FavoriteIconViewModel: ObservableObject {
    @MainActor @Published var favicon: Favicon = .empty

    let domain: String
    let onFaviconMissing: (() -> Void)?

    init(domain: String, onFaviconMissing: (() -> Void)?) {
        self.domain = domain
        self.onFaviconMissing = onFaviconMissing
    }

    @MainActor
    func loadFavicon(size: CGFloat) async {
        self.favicon = createFakeFavicon(for: domain, size: size)

        let faviconResult = await FaviconsHelper.loadFaviconSync(forDomain: domain, usingCache: .fireproof, useFakeFavicon: false)
        if let iconImage = faviconResult.image {
            let useBorder = URL.isDuckDuckGo(domain: self.domain) || iconImage.size.width < size
            self.favicon = Favicon(image: iconImage, isUsingBorder: useBorder)
        } else {
            onFaviconMissing?()
        }
    }

    private func createFakeFavicon(for domain: String, size: CGFloat) -> Favicon {
        let color = UIColor.forDomain(domain)
        let icon = FaviconsHelper.createFakeFavicon(
            forDomain: domain,
            size: size,
            backgroundColor: color,
            bold: false
        ) ?? UIImage()

        return Favicon(image: icon, isUsingBorder: false)
    }
}

struct Favicon {
    let image: UIImage
    let isUsingBorder: Bool

    static let empty = Self.init(image: UIImage(), isUsingBorder: false)
}
