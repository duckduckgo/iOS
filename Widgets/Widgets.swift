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

import Common
import WidgetKit
import SwiftUI
import Core
import CoreData
import Kingfisher
import Bookmarks
import Persistence
import NetworkExtension

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
            os_log("BookmarksDatabase load store started")
            db.loadStore { _, error in
                guard error == nil else { return }
                self.bookmarksDB = db
            }
            os_log("BookmarksDatabase store loaded")
        }
        
        if maxFavorites > 0,
           let db = bookmarksDB {
            let model = FavoritesListViewModel(bookmarksDatabase: db)
            os_log("model created")
            let dbFavorites = model.favorites
            os_log("dbFavorites loaded %d", dbFavorites.count)
            let favorites = coreDataFavoritesToFavorites(dbFavorites, returningNoMoreThan: maxFavorites)
            os_log("favorites converted %d", favorites.count)
            let entry = FavoritesEntry(date: Date(), favorites: favorites, isPreview: favorites.isEmpty && context.isPreview)
            os_log("entry created")
            completion(entry)
        } else {
            let entry = FavoritesEntry(date: Date(), favorites: [], isPreview: context.isPreview)
            completion(entry)
        }
    }

    private func loadImageFromCache(forDomain domain: String?) -> UIImage? {
        guard let domain = domain else { return nil }

        let key = Favicons.createHash(ofDomain: domain)
        guard let cacheUrl = Favicons.CacheType.fireproof.cacheLocation() else { return nil }

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

@main
struct Widgets: WidgetBundle {

    @WidgetBundleBuilder
    var body: some Widget {
        SearchWidget()
        FavoritesWidget()

        if #available(iOSApplicationExtension 17.0, *) {
            VPNStatusWidget()
        }

        if #available(iOSApplicationExtension 16.0, *) {
            SearchLockScreenWidget()
            VoiceSearchLockScreenWidget()
            EmailProtectionLockScreenWidget()
            FireButtonLockScreenWidget()
            FavoritesLockScreenWidget()
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

// MARK: - VPN Status Widget

enum VPNStatus {
    case status(NEVPNStatus)
    case error
    case notConfigured
}
struct VPNStatusTimelineEntry: TimelineEntry {
    let date: Date
    let status: VPNStatus
    let location: String

    internal init(date: Date, status: VPNStatus = .notConfigured, location: String = "No Location") {
        self.date = date
        self.status = status
        self.location = location
    }
}

class VPNStatusTimelineProvider: TimelineProvider {

    typealias Entry = VPNStatusTimelineEntry

    func placeholder(in context: Context) -> VPNStatusTimelineEntry {
        return VPNStatusTimelineEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (VPNStatusTimelineEntry) -> Void) {
        let entry = VPNStatusTimelineEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VPNStatusTimelineEntry>) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            let expiration = Date().addingTimeInterval(TimeInterval.minutes(1))

            if let error {
                let entry = VPNStatusTimelineEntry(date: expiration, status: .error)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
                return
            }

            guard let manager = managers?.first else {
                let entry = VPNStatusTimelineEntry(date: expiration, status: .notConfigured)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
                return
            }

            let status = manager.connection.status
            let enabled = (status == .connected || status == .connecting)

            let entry = VPNStatusTimelineEntry(date: expiration, status: .status(status))
            let timeline = Timeline(entries: [entry], policy: .atEnd)

            completion(timeline)
        }
    }
}

extension NEVPNStatus {
    var description: String {
        switch self {
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting"
        case .disconnected:
            return "Disconnected"
        case .disconnecting:
            return "Disconnecting"
        case .invalid:
            return "Invalid"
        case .reasserting:
            return "Reasserting"
        default:
            return "Unknown Status"
        }
    }
}

struct VPNStatusView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: VPNStatusTimelineProvider.Entry

    @ViewBuilder
    var body: some View {
        if #available(iOSApplicationExtension 17.0, *) {
            VStack {
                switch entry.status {
                case .status(let status):
                    Text(status.description)
                    // Text("Location: \(entry.location)").font(.footnote)

                    Spacer()

                    switch status {
                    case .connected:
                        Button(intent: DisableVPNIntent()) {
                            Text("Disconnect")
                                .font(.body)
                                .padding()
                                .background(Color.black)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    case .disconnected:
                        Button(intent: EnableVPNIntent()) {
                            Text("Connect")
                                .font(.body)
                                .padding()
                                .background(Color.black)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    default:
                        Text("Changing status...")
                    }
                case .error:
                    Text("Error")
                case .notConfigured:
                    Text("VPN Not Configured")
                }
            }
            .containerBackground(for: .widget) {
                Color.orange
            }
        } else {
            Text("iOS 17 required")
        }
    }
}

struct VPNStatusWidget: Widget {
    let kind: String = "VPNStatusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VPNStatusTimelineProvider()) { entry in
            VPNStatusView(entry: entry)
        }
        .configurationDisplayName("VPN Status")
        .description("View and manage the DuckDuckGo VPN status")
        .supportedFamilies([.systemSmall])
    }
}
