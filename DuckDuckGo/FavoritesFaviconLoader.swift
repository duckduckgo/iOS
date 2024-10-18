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
    
    private var tasks: [String: Task<Favicon?, Never>] = [:]

    func loadFavicon(for favorite: Favorite, size: CGFloat) async -> Favicon? {
        let domain = favorite.domain

        if let task = tasks[domain] {
            if task.isCancelled {
                tasks.removeValue(forKey: domain)
            } else {
                return await task.value
            }
        }

        let newTask = Task<Favicon?, Never> {
            let faviconResult = FaviconsHelper.loadFaviconSync(forDomain: domain, usingCache: .fireproof, useFakeFavicon: false)
            return Favicon(domain: domain, expectedSize: size, faviconResult: faviconResult)
        }

        tasks[domain] = newTask
        let value = await newTask.value
        if value == nil {
            tasks[domain] = nil
        }

        return value
    }

    nonisolated func existingFavicon(for favorite: Favorite, size: CGFloat) -> Favicon? {
        let result = FaviconsHelper.loadFaviconSync(forDomain: favorite.domain, usingCache: .fireproof, useFakeFavicon: false)
        return Favicon(domain: favorite.domain, expectedSize: size, faviconResult: result)
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
            return Favicon(image: icon, isUsingBorder: false, isFake: true)
        } else {
            return .empty
        }
    }
}

private extension Favicon {
    init?(domain: String, expectedSize: CGFloat, faviconResult: (image: UIImage?, isFake: Bool)) {
        guard let iconImage = faviconResult.image else {
            return nil
        }

        let useBorder = URL.isDuckDuckGo(domain: domain) || iconImage.size.width < expectedSize
        self.init(image: iconImage, isUsingBorder: useBorder, isFake: faviconResult.isFake)
    }
}
