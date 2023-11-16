//
//  DeepLinks.swift
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

import Core

struct DeepLinks {

    static let newSearch = AppDeepLinkSchemes.newSearch.url
    static let voiceSearch = AppDeepLinkSchemes.voiceSearch.url
    static let newEmail = AppDeepLinkSchemes.newEmail.url
    static let fireButton = AppDeepLinkSchemes.fireButton.url
    static let favorites = AppDeepLinkSchemes.favorites.url

    static let addFavorite = AppDeepLinkSchemes.addFavorite.url

    static let openVPN = AppDeepLinkSchemes.openVPN.url
}
