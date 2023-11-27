//
//  AppDeepLinkSchemes.swift
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

public enum AppDeepLinkSchemes: String, CaseIterable {

    case newSearch = "ddgNewSearch"
    case voiceSearch = "ddgVoiceSearch"
    case fireButton = "ddgFireButton"
    case favorites = "ddgFavorites"
    case newEmail = "ddgNewEmail"

    case quickLink = "ddgQuickLink"

    case addFavorite = "ddgAddFavorite"

    case openVPN = "ddgOpenVPN"

    public var url: URL {
        URL(string: rawValue + "://")!
    }

    public func appending(_ string: String) -> String {
        "\(rawValue)://\(string)"
    }

    public static func fromURL(_ url: URL) -> AppDeepLinkSchemes? {
        guard let scheme = url.scheme else { return nil }
        return allCases.first(where: { $0.rawValue.lowercased() == scheme.lowercased() })
    }

    public static func query(fromQuickLink url: URL) -> String {
        let query = url.absoluteString
            .replacingOccurrences(of: AppDeepLinkSchemes.quickLink.url.absoluteString,
                                  with: "",
                                  options: .caseInsensitive)

        return AppDeepLinkSchemes.fixURLScheme(query)
    }

    private static func fixURLScheme(_ urlString: String) -> String {
        let pattern = "^https?//"

        if urlString.range(of: pattern, options: .regularExpression) != nil {
            return urlString.replacingOccurrences(of: "//", with: "://")
        } else {
            return urlString
        }
    }
}
