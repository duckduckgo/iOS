//
//  AppDeepLinks.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

public struct AppDeepLinks {

    public static let newSearch = "ddgNewSearch://"

    public static let quickLink = "ddgQuickLink://"

    public static let bookmarks = "ddgBookmarks://"
    
    public static let fire = "ddgFire://"

    public static let launchFavorite = "ddgFavorite://"

    public static let addFavorite = "ddgAddFavorite://"

    public static let aboutLink = URL(string: "\(AppDeepLinks.quickLink)duckduckgo.com/about")!

    public static func isLaunchFavorite(url: URL) -> Bool {
        return isUrl(url, deepLink: launchFavorite)
    }

    public static func isNewSearch(url: URL) -> Bool {
        return isUrl(url, deepLink: AppDeepLinks.newSearch)
    }

    public static func isQuickLink(url: URL) -> Bool {
        return isUrl(url, deepLink: AppDeepLinks.quickLink)
    }
    
    public static func isBookmarks(url: URL) -> Bool {
        return isUrl(url, deepLink: AppDeepLinks.bookmarks)
    }
    
    public static func isFire(url: URL) -> Bool {
        return isUrl(url, deepLink: AppDeepLinks.fire)
    }

    public static func isAddFavorite(url: URL) -> Bool {
        return isUrl(url, deepLink: AppDeepLinks.addFavorite)
    }
    
    private static func isUrl(_ url: URL, deepLink: String) -> Bool {
        if let scheme = url.scheme {
            return deepLink.lowercased().contains(scheme.lowercased())
        }
        return false
    }

    public static func query(fromQuickLink url: URL) -> String {
        return url.absoluteString.replacingOccurrences(of: quickLink, with: "", options: .caseInsensitive)
    }

    public static func query(fromLaunchFavorite url: URL) -> String {
        return url.absoluteString.replacingOccurrences(of: launchFavorite, with: "", options: .caseInsensitive)
    }
}
