//
//  UserText.swift
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

import Foundation

struct UserText {

    static let favoritesWidgetGalleryDisplayName = NSLocalizedString("widget.gallery.search.and.favorites.display.name",
                                                                     value: "Search and Favorites",
                                                                     comment: "Display name for search and favorites widget in widget gallery")

    static let favoritesWidgetGalleryDescription = NSLocalizedString("widget.gallery.search.and.favorites.description",
                                                                     value: "Search or visit your favorite sites privately with just one tap.",
                                                                     comment: "Description of search and favorites widget in widget gallery")

    static let searchWidgetGalleryDisplayName = NSLocalizedString("widget.gallery.search.display.name",
                                                                  value: "Search",
                                                                  comment: "Display name for search only widget in widget gallery")

    static let searchWidgetGalleryDescription = NSLocalizedString("widget.gallery.search.description",
                                                                  value: "Quickly launch a private search in DuckDuckGo.",
                                                                  comment: "Description of search only widget in widget gallery")

    static let searchDuckDuckGo = NSLocalizedString("widget.search.duckduckgo",
                                                    value: "Search DuckDuckGo",
                                                    comment: "Placeholder text in search field on the search and favorites widget")

    static let noFavoritesMessage = NSLocalizedString("widget.no.favorites.message",
                                                      value: "Quickly visit your favorite sites.",
                                                      comment: "Message shown in the favorites widget empty state.")

    static let noFavoritesCTA = NSLocalizedString("widget.no.favorites.cta",
                                                  value: "Add Favorites",
                                                  comment: "CTA shown in the favorites widget empty state.")

    static let lockScreenSearchTitle = NSLocalizedString(
        "lock.screen.widget.search.title",
        value: "Private Search",
        comment: "Title shown to the user when adding the Search lock screen widget")

    static let lockScreenSearchDescription = NSLocalizedString(
        "lock.screen.widget.search.description",
        value: "Instantly start a private search in DuckDuckGo.",
        comment: "Description shown to the user when adding the Search lock screen widget")

    static let lockScreenFavoritesTitle = NSLocalizedString(
        "lock.screen.widget.favorites.title",
        value: "Favorites",
        comment: "Title shown to the user when adding the favorites lock screen widget")

    static let lockScreenFavoritesDescription = NSLocalizedString(
        "lock.screen.widget.favorites.description",
        value: "Quickly open your favorite websites with a tap.",
        comment: "Description shown to the user when adding the Search lock screen widget")

    static let lockScreenVoiceTitle = NSLocalizedString(
        "lock.screen.widget.voice.title",
        value: "Voice Search",
        comment: "Title shown to the user when adding the Voice Search lock screen widget")

    static let lockScreenVoiceDescription = NSLocalizedString(
        "lock.screen.widget.voice.description",
        value: "Instantly start a new private voice search in DuckDuckGo.",
        comment: "Description shown to the user when adding the Voice Search lock screen widget")

    static let lockScreenEmailTitle = NSLocalizedString(
        "lock.screen.widget.email.title",
        value: "Email Protection",
        comment: "Title shown to the user when adding the Email Protection lock screen widget")

    static let lockScreenEmailDescription = NSLocalizedString(
        "lock.screen.widget.email.description",
        value: "Instantly generate a new private Duck Address.",
        comment: "Description shown to the user when adding the Email Protection lock screen widget")

    static let lockScreenFireTitle = NSLocalizedString(
        "lock.screen.widget.fire.title",
        value: "Fire Button",
        comment: "Title shown to the user when adding the Fire Button lock screen widget")

    static let lockScreenFireDescription = NSLocalizedString(
        "lock.screen.widget.fire.description",
        value: "Instantly delete your browsing history and start a new private search in DuckDuckGo.",
        comment: "Description shown to the user when adding the Fire Button lock screen widget")
}
