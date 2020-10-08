//
//  Widgets.swift
//  Widgets
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import WidgetKit
import SwiftUI
import Core
import Kingfisher

struct Favorite {

    static let ddgDomain = "duckduckgo.com"

    let url: URL
    let domain: String
    let favicon: UIImage?

    var isDuckDuckGo: Bool {
        return domain == Self.ddgDomain
    }

    var needsColorBackground: Bool {
        return favicon == nil && domain != Self.ddgDomain
    }

}

struct Provider: TimelineProvider {

    typealias Entry = FavoritesEntry

    func getSnapshot(in context: Context, completion: @escaping (FavoritesEntry) -> Void) {
        completion(createEntry(in: context))
    }

    func placeholder(in context: Context) -> FavoritesEntry {
        return createEntry(in: context)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FavoritesEntry>) -> Void) {
        let timeline = Timeline(entries: [createEntry(in: context)], policy: .never)
        completion(timeline)
    }

    private func getFavorites(returningNoMoreThan maxLength: Int) -> [Favorite] {
        return BookmarkUserDefaults().favorites.prefix(maxLength)
            .map {
                return Favorite(url: DeepLinks.createFavoriteLauncher(forUrl: $0.url),
                                domain: $0.url.host?.dropPrefix(prefix: "www.") ?? "",
                                favicon: loadImageFromCache(forDomain: $0.url.host) )
            }
    }

    private func createEntry(in context: Context) -> FavoritesEntry {
        let favorites: [Favorite]

        switch context.family {

        case .systemMedium:
            favorites = getFavorites(returningNoMoreThan: 4)

        case .systemLarge:
            favorites = getFavorites(returningNoMoreThan: 12)

        default:
            favorites = []
        }

        return FavoritesEntry(date: Date(), favorites: favorites, isPreview: favorites.isEmpty && context.isPreview)
    }

    private func loadImageFromCache(forDomain domain: String?) -> UIImage? {
        guard let domain = domain else { return nil }

        let key = Favicons.createHash(ofDomain: domain)
        guard let cacheUrl = Favicons.CacheType.bookmarks.cacheLocation() else { return nil }

        // Slight leap here to avoid loading Kingisher as a library for the widgets.
        // Once dependency management is fixed, link it and use Favicons directly.
        let imageUrl = cacheUrl.appendingPathComponent("com.onevcat.Kingfisher.ImageCache.bookmarks").appendingPathComponent(key)

        guard let data = (try? Data(contentsOf: imageUrl)) else { return nil }

        return UIImage(data: data)
    }

}

struct FavoritesEntry: TimelineEntry {

    let date: Date
    let favorites: [Favorite]
    let isPreview: Bool

    func favoriteAt(index: Int) -> Favorite? {
        guard index < favorites.count else { return nil }
        return favorites[index]
    }

}

struct SearchWidget: Widget {
    let kind: String = "SearchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            return SearchWidgetView(entry: entry).widgetURL(DeepLinks.newSearch)
        }
        .configurationDisplayName(UserText.searchWidgetGalleryDisplayName)
        .description(UserText.searchWidgetGalleryDescription)
        .supportedFamilies([.systemSmall])
    }

}

struct FavoritesWidget: Widget {
    let kind: String = "FavoritesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FavoritesWidgetView(entry: entry)
        }
        .configurationDisplayName(UserText.favoritesWidgetGalleryDisplayName)
        .description(UserText.favoritesWidgetGalleryDescription)
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

@main
struct Widgets: WidgetBundle {

    @WidgetBundleBuilder
    var body: some Widget {
        SearchWidget()
        FavoritesWidget()
    }

}

