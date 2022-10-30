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

    public static let launchFavorite = "ddgFavorite://"
    public static let launchFavoriteHttps = "ddgFavoriteHttps://"

    public static let addFavorite = "ddgAddFavorite://"

    public static let aboutLink = URL(string: "\(AppDeepLinks.quickLink)duckduckgo.com/about")!
    public static let webTrackingProtections = URL(string: "\(AppDeepLinks.quickLink)help.duckduckgo.com/duckduckgo-help-pages/privacy/web-tracking-protections/")!
    public static let thirdPartyTrackerLoadingProtection = URL(string: "\(AppDeepLinks.quickLink)help.duckduckgo.com/duckduckgo-help-pages/privacy/web-tracking-protections/#3rd-party-tracker-loading-protection")!

    public static func isLaunchFavorite(url: URL) -> Bool {
        return isUrl(url, deepLink: launchFavorite) || isUrl(url, deepLink: launchFavoriteHttps)
    }

    public static func isNewSearch(url: URL) -> Bool {
        return isUrl(url, deepLink: AppDeepLinks.newSearch)
    }

    public static func isQuickLink(url: URL) -> Bool {
        return isUrl(url, deepLink: AppDeepLinks.quickLink)
    }

    public static func isAddFavorite(url: URL) -> Bool {
        return isUrl(url, deepLink: AppDeepLinks.addFavorite)
    }
    
    private static func isUrl(_ url: URL, deepLink: String) -> Bool {
        if let scheme = url.scheme {
            let cleanDeepLink = deepLink.dropping(suffix: "://")
            return cleanDeepLink.lowercased() == scheme.lowercased()
        }
        return false
    }

    public static func query(fromQuickLink url: URL) -> String {
        return url.absoluteString.replacingOccurrences(of: quickLink, with: "", options: .caseInsensitive)
    }

    public static func query(fromLaunchFavorite url: URL) -> String {
        var newQuery = url.absoluteString
        if newQuery.hasPrefix(launchFavoriteHttps) {
            newQuery = "https://" + newQuery.dropping(prefix: launchFavoriteHttps)
        } else if newQuery.hasPrefix(launchFavorite) {
            newQuery = "http://" + newQuery.dropping(prefix: launchFavorite)
        }
        return newQuery
    }
}
