//
//  FavoritesFaviconLoader.swift
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

import UIKit

actor FavoritesFaviconLoader: FavoritesFaviconLoading {
    private var tasks: [URL: Task<Favicon?, Never>] = [:]
    private(set) var onFaviconMissing: (() async -> Void)?

    init(onFaviconMissing: (() async -> Void)? = nil) {
        self.onFaviconMissing = onFaviconMissing
    }

    func loadFavicon(for favorite: Favorite, size: CGFloat) async -> Favicon? {
        guard let url = favorite.urlObject else { return nil }

        if let task = tasks[url] {
            if task.isCancelled {
                tasks.removeValue(forKey: url)
            } else {
                return await task.value
            }
        }

        let newTask = Task<Favicon?, Never> {
            let faviconResult = await FaviconsHelper.loadFaviconSync(forDomain: favorite.domain, usingCache: .fireproof, useFakeFavicon: false)
            if let iconImage = faviconResult.image {
                let useBorder = URL.isDuckDuckGo(domain: favorite.domain) || iconImage.size.width < size

                return Favicon(image: iconImage, isUsingBorder: useBorder)
            } else {
                await onFaviconMissing?()
                return nil
            }
        }

        tasks[url] = newTask

        return await newTask.value
    }

    nonisolated func fakeFavicon(for favorite: Favorite, size: CGFloat) -> Favicon {
        let domain = favorite.domain
        let color = UIColor.forDomain(domain)
        let icon = FaviconsHelper.createFakeFavicon(
            forDomain: domain,
            size: 64,
            backgroundColor: color,
            bold: false
        )

        if let icon {
            return Favicon(image: icon, isUsingBorder: false)
        } else {
            return .empty
        }
    }
}
