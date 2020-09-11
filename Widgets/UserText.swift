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

}
