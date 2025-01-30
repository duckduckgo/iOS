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

import AppIntents
import Common
import WidgetKit
import SwiftUI
import Core
import CoreData
import Kingfisher
import Bookmarks
import Persistence
import NetworkExtension
import os.log

struct Favorite {

    static let ddgDomain = "duckduckgo.com"

    let url: URL
    let domain: String
    let title: String
    let favicon: UIImage?

    var isDuckDuckGo: Bool {
        return domain == Self.ddgDomain
    }

    var needsColorBackground: Bool {
        return favicon == nil && domain != Self.ddgDomain
    }

}

class Provider: TimelineProvider {

    typealias Entry = FavoritesEntry
    
    var bookmarksDB: CoreDataDatabase?

    func getSnapshot(in context: Context, completion: @escaping (FavoritesEntry) -> Void) {
        createEntry(in: context) { entry in
            completion(entry)
        }
    }

    func placeholder(in context: Context) -> FavoritesEntry {
        return FavoritesEntry(date: Date(), favorites: [], isPreview: context.isPreview)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FavoritesEntry>) -> Void) {
        createEntry(in: context) { entry in
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
        }
    }
    
    private func coreDataFavoritesToFavorites(_ coreDataFavorites: [BookmarkEntity], returningNoMoreThan maxLength: Int) -> [Favorite] {
        
        let favorites: [Favorite] = coreDataFavorites.compactMap { favorite -> Favorite? in
            guard let url = favorite.urlObject,
                  !url.isBookmarklet(),
                  let domain = url.host?.droppingWwwPrefix()
            else { return nil }

            return Favorite(url: url,
                            domain: domain,
                            title: favorite.title ?? domain,
                            favicon: loadImageFromCache(forDomain: url.host) )
        }
        
        return Array(favorites.prefix(maxLength))
            
    }

    private func createEntry(in context: Context, completion: @escaping (FavoritesEntry) -> Void) {
        let maxFavorites: Int
        switch context.family {

        case .systemMedium:
            maxFavorites = 4

        case .systemLarge:
            maxFavorites = 12

        default:
            maxFavorites = 0
        }
        
        if bookmarksDB == nil {
            let db = BookmarksDatabase.make(readOnly: true)
            Logger.general.debug("BookmarksDatabase load store started")
            db.loadStore { _, error in
                guard error == nil else { return }
                self.bookmarksDB = db
            }
            Logger.general.debug("BookmarksDatabase store loaded")
        }
        
        if maxFavorites > 0,
           let db = bookmarksDB {
            let model = FavoritesListViewModel(bookmarksDatabase: db, favoritesDisplayMode: fetchFavoritesDisplayMode())
            Logger.general.debug("model created")
            let dbFavorites = model.favorites
            Logger.general.debug("dbFavorites loaded \(dbFavorites.count)")
            let favorites = coreDataFavoritesToFavorites(dbFavorites, returningNoMoreThan: maxFavorites)
            Logger.general.debug("favorites converted \(favorites.count)")
            let entry = FavoritesEntry(date: Date(), favorites: favorites, isPreview: favorites.isEmpty && context.isPreview)
            Logger.general.debug("entry created")
            completion(entry)
        } else {
            let entry = FavoritesEntry(date: Date(), favorites: [], isPreview: context.isPreview)
            completion(entry)
        }
    }

    private func fetchFavoritesDisplayMode() -> FavoritesDisplayMode {
        let userDefaults = UserDefaults(suiteName: "group.com.duckduckgo.bookmarks")
        let displayModeDescription = userDefaults?.string(forKey: "com.duckduckgo.ios.favoritesDisplayMode")

        if let displayModeDescription, let displayMode = FavoritesDisplayMode(displayModeDescription) {
            return displayMode
        }
        return .displayNative(.mobile)
    }

    private func loadImageFromCache(forDomain domain: String?) -> UIImage? {
        guard let domain = domain else { return nil }

        let key = FaviconHasher.createHash(ofDomain: domain)
        guard let cacheUrl = FaviconsCacheType.fireproof.cacheLocation() else { return nil }

        // Slight leap here to avoid loading Kingisher as a library for the widgets.
        // Once dependency management is fixed, link it and use Favicons directly.
        let imageUrl = cacheUrl.appendingPathComponent("com.onevcat.Kingfisher.ImageCache.fireproof").appendingPathComponent(key)

        guard let data = (try? Data(contentsOf: imageUrl)) else { return nil }

        return UIImage(data: data)?.toSRGB()
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

struct PasswordsWidget: Widget {
    let kind: String = "PasswordsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PasswordsWidgetView(entry: entry).widgetURL(DeepLinks.openPasswords)
        }
        .configurationDisplayName(UserText.passwordsWidgetGalleryDisplayName)
        .description(UserText.passwordsWidgetGalleryDescription)
        .supportedFamilies([.systemSmall])
    }

}

@main
struct Widgets: WidgetBundle {

    @WidgetBundleBuilder
    var body: some Widget {
        makeWidgets()
    }

    @available(iOSApplicationExtension 16.0, *)
    private var lockScreenWidgets: some Widget {
        WidgetBundleBuilder.buildBlock(
                 SearchLockScreenWidget(),
                 VoiceSearchLockScreenWidget(),
                 EmailProtectionLockScreenWidget(),
                 FireButtonLockScreenWidget(),
                 FavoritesLockScreenWidget(),
                 AIChatLockScreenWidget(),
                 PasswordsLockScreenWidget()
             )
    }

    private func makeWidgets() -> some Widget {
        if #available(iOS 17, *) {
            return WidgetBundleBuilder.buildBlock(QuickActionsWidget(),
                                                  FavoritesWidget(),
                                                  PasswordsWidget(),
                                                  VPNBundle().body,
                                                  SearchWidget(),
                                                  lockScreenWidgets)
        }
        
        if #available(iOS 16.0, *) {
            return WidgetBundleBuilder.buildBlock(SearchWidget(),
                                                  PasswordsWidget(),
                                                  FavoritesWidget(),
                                                  lockScreenWidgets)
        } else {
            return WidgetBundleBuilder.buildBlock(SearchWidget(),
                                                  PasswordsWidget(),
                                                  FavoritesWidget())
        }
    }
}

struct VPNBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        if #available(iOS 17, *) {
            VPNStatusWidget()
            VPNSnoozeLiveActivity()
        }

        if #available(iOS 18, *) {
            VPNControlWidget()
            AIChatControlWidget()
        }
    }
}


extension UIImage {

    func toSRGB() -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

}
