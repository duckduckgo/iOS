//
//  Widgets.swift
//  Widgets
//
//  Created by Chris Brind on 19/08/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
        NSLog("getTimeline for %@", String(describing: context.family))
        let timeline = Timeline(entries: [createEntry(in: context)], policy: .atEnd)
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
            favorites = getFavorites(returningNoMoreThan: 8)

        default:
            favorites = []
        }

        NSLog("*** favorites %@", favorites)

        return FavoritesEntry(date: Date(), favorites: favorites, isPreview: favorites.isEmpty && context.isPreview)
    }

    private func loadImageFromCache(forDomain domain: String?) -> UIImage? {
        NSLog("*** load image for domain %@", domain ?? "<nil>")
        guard let domain = domain else { return nil }

        let key = Favicons.createHash(ofDomain: domain)
        guard let cacheUrl = Favicons.CacheType.bookmarks.cacheLocation() else { return nil }

        // Slight leap here to avoid loading Kingisher as a library for the widgets.
        // Once dependency management is fixed, link it and use Favicons directly.
        let imageUrl = cacheUrl.appendingPathComponent("com.onevcat.Kingfisher.ImageCache.bookmarks").appendingPathComponent(key)
        NSLog("*** imageUrl %@", imageUrl.absoluteString)

        guard let data = (try? Data(contentsOf: imageUrl)) else {
            NSLog("*** data is nil for url %@", imageUrl.absoluteString)
            return nil
        }

        let image = UIImage(data: data)
        NSLog("*** image is size %@", String(describing: image?.size))
        return image
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
        .configurationDisplayName("Search")
        .description("Quickly launch a private search in DuckDuckGo.")
        .supportedFamilies([.systemSmall])
    }

}

struct FavoritesWidget: Widget {
    let kind: String = "FavoritesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FavoritesWidgetView(entry: entry)
        }
        .configurationDisplayName("Search and Favorites")
        .description("Search or visit your favorite sites privately with just one tap.")
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

