//
//  WidgetViews.swift
//  DuckDuckGo
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

struct FavoriteView: View {

    var favorite: Favorite?
    var isPreview: Bool

    var body: some View {

        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.widgetFavoritesBackground)

            if let favorite = favorite {

                Link(destination: favorite.url) {

                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(favorite.needsColorBackground ? Color.forDomain(favorite.domain) : Color.widgetFavoritesBackground)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                        
                        if let image = favorite.favicon {
                            
                            Image(uiImage: image)
                                .scaleDown(image.size.width > 60)
                                .cornerRadius(10)
                            
                        } else if favorite.isDuckDuckGo {
                            
                            Image("WidgetDaxLogo")
                                .resizable()
                                .frame(width: 45, height: 45, alignment: .center)
                            
                        } else {
                            
                            Text(favorite.domain.first?.uppercased() ?? "")
                                .foregroundColor(Color.widgetFavoriteLetter)
                                .font(.system(size: 42))
                            
                        }

                    }

                }
                .accessibilityLabel(Text(favorite.title))

            }

        }
        .frame(width: 60, height: 60, alignment: .center)

    }

}

struct LargeSearchFieldView: View {

    var body: some View {
        Link(destination: DeepLinks.newSearch) {
            ZStack {

                Capsule(style: .circular)
                    .fill(Color.widgetSearchFieldBackground)
                    .frame(minHeight: 46, maxHeight: 46)
                    .padding(16)

                HStack {

                    Image("WidgetDaxLogo")
                        .resizable()
                        .frame(width: 24, height: 24, alignment: .leading)

                    Text(UserText.searchDuckDuckGo)
                        .foregroundColor(Color.widgetSearchFieldText)

                    Spacer()

                    Image("WidgetSearchLoupe")

                }.padding(EdgeInsets(top: 0, leading: 27, bottom: 0, trailing: 27))

            }.unredacted()
        }
    }

}

struct FavoritesRowView: View {

    var entry: Provider.Entry
    var start: Int
    var end: Int

    var body: some View {
        HStack {
            ForEach(start...end, id: \.self) {
                FavoriteView(favorite: entry.favoriteAt(index: $0), isPreview: entry.isPreview)

                if $0 < end {
                    Spacer()
                }

            }
        }
        .padding(.horizontal, 16)

    }

}

struct FavoritesGridView: View {

    @Environment(\.widgetFamily) var widgetFamily

    var entry: Provider.Entry

    var body: some View {

        FavoritesRowView(entry: entry, start: 0, end: 3)

        Spacer()

        if widgetFamily == .systemLarge {

            FavoritesRowView(entry: entry, start: 4, end: 7)

            Spacer()

            FavoritesRowView(entry: entry, start: 8, end: 11)

            Spacer()

        }

    }

}

struct FavoritesWidgetView: View {

    @Environment(\.widgetFamily) var widgetFamily

    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Rectangle().fill(Color.widgetBackground)

            VStack(alignment: .center, spacing: 0) {

                LargeSearchFieldView()

                if entry.favorites.isEmpty, !entry.isPreview {
                    Link(destination: DeepLinks.addFavorite) {
                        FavoritesGridView(entry: entry).accessibilityLabel(Text(UserText.noFavoritesCTA))
                    }
                } else {
                    FavoritesGridView(entry: entry)
                }

            }.padding(.bottom, 8)

            VStack(spacing: 8) {
                Text(UserText.noFavoritesMessage)
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.widgetAddFavoriteMessage)
                    .padding(.horizontal)
                    .accessibilityHidden(true)

                HStack {
                    Text(UserText.noFavoritesCTA)
                        .bold()
                        .font(.system(size: 15))
                        .foregroundColor(.widgetAddFavoriteCTA)

                    Image(systemName: "chevron.right")
                        .imageScale(.medium)
                        .foregroundColor(.widgetAddFavoriteCTA)
                }.accessibilityHidden(true)

            }
            .isVisible(entry.favorites.isEmpty && !entry.isPreview)
            .padding(EdgeInsets(top: widgetFamily == .systemLarge ? 48 : 60, leading: 0, bottom: 0, trailing: 0))

        }
    }
}

struct SearchWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.widgetBackground)
                .accessibilityLabel(Text(UserText.searchDuckDuckGo))

            VStack(alignment: .center, spacing: 15) {

                Image("WidgetDaxLogo")
                    .resizable()
                    .frame(width: 46, height: 46, alignment: .center)
                    .isHidden(false)
                    .accessibilityHidden(true)

                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {

                    Capsule(style: .circular)
                        .fill(Color.widgetSearchFieldBackground)
                        .frame(width: 123, height: 46)

                    Image("WidgetSearchLoupe")
                        .padding(.trailing)
                        .isHidden(false)

                }
            }.accessibilityHidden(true)
        }
    }
}

// See https://stackoverflow.com/a/59228385/73479
extension View {

    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    /// ```
    /// Text("Label")
    ///     .isHidden(true)
    /// ```
    ///
    /// Example for complete removal:
    /// ```
    /// Text("Label")
    ///     .isHidden(true, remove: true)
    /// ```
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }

    /// Logically inverse of `isHidden`
    @ViewBuilder func isVisible(_ visible: Bool, remove: Bool = false) -> some View {
        self.isHidden(!visible, remove: remove)
    }

}

extension Image {

    @ViewBuilder func scaleDown(_ shouldScale: Bool) -> some View {
        if shouldScale {
            self.resizable().aspectRatio(contentMode: .fit)
        } else {
            self
        }
    }

}

struct WidgetViews_Previews: PreviewProvider {

    static let mockFavorites: [Favorite] = {
        let duckDuckGoFavorite = Favorite(url: URL(string: "https://duckduckgo.com/")!,
                                          domain: "duckduckgo.com",
                                          title: "title",
                                          favicon: nil)

        let favorites = "abcdefghijk".map {
            Favorite(url: URL(string: "https://\($0).com/")!, domain: "\($0).com", title: "title", favicon: nil)
        }

        return [duckDuckGoFavorite] + favorites
    }()

    static let withFavorites = FavoritesEntry(date: Date(), favorites: mockFavorites, isPreview: false)
    static let previewWithFavorites = FavoritesEntry(date: Date(), favorites: mockFavorites, isPreview: true)
    static let emptyState = FavoritesEntry(date: Date(), favorites: [], isPreview: false)
    static let previewEmptyState = FavoritesEntry(date: Date(), favorites: [], isPreview: true)

    static var previews: some View {
        SearchWidgetView(entry: emptyState)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .environment(\.colorScheme, .light)

        SearchWidgetView(entry: emptyState)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .environment(\.colorScheme, .dark)

        // Medium size:

        FavoritesWidgetView(entry: previewWithFavorites)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environment(\.colorScheme, .light)

        FavoritesWidgetView(entry: withFavorites)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environment(\.colorScheme, .light)

        FavoritesWidgetView(entry: previewEmptyState)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environment(\.colorScheme, .dark)

        FavoritesWidgetView(entry: emptyState)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environment(\.colorScheme, .dark)

        // Large size:

        FavoritesWidgetView(entry: previewWithFavorites)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .environment(\.colorScheme, .light)

        FavoritesWidgetView(entry: withFavorites)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .environment(\.colorScheme, .light)

        FavoritesWidgetView(entry: previewEmptyState)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .environment(\.colorScheme, .dark)

        FavoritesWidgetView(entry: emptyState)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .environment(\.colorScheme, .dark)
    }
}
