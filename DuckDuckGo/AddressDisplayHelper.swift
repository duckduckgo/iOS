//
//  AddressDisplayHelper.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import DuckPlayer

extension OmniBar {

    struct AddressDisplayHelper {

        static func addressForDisplay(url: URL, showsFullURL: Bool) -> NSAttributedString {
            
            if url.isDuckPlayer,
                let playerURL = getDuckPlayerURL(url: url, showsFullURL: showsFullURL) {
                return playerURL
            }
            
            if !showsFullURL, let shortAddress = shortURLString(url) {
                return NSAttributedString(
                    string: shortAddress,
                    attributes: [.foregroundColor: ThemeManager.shared.currentTheme.searchBarTextColor])
                                
            } else {
                return deemphasisePath(forUrl: url)
            }
        }

        static func deemphasisePath(forUrl url: URL) -> NSAttributedString {
            
            let s = url.absoluteString
            let attributedString = NSMutableAttributedString(string: s)
            guard let c = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return attributedString
            }

            let theme = ThemeManager.shared.currentTheme

            if let pathStart = c.rangeOfPath?.lowerBound {
                let urlEnd = s.endIndex

                let pathRange = NSRange(pathStart ..< urlEnd, in: s)
                attributedString.addAttribute(.foregroundColor, value: theme.searchBarTextDeemphasisColor, range: pathRange)

                let domainRange = NSRange(s.startIndex ..< pathStart, in: s)
                attributedString.addAttribute(.foregroundColor, value: theme.searchBarTextColor, range: domainRange)

            } else {
                let range = NSRange(s.startIndex ..< s.endIndex, in: s)
                attributedString.addAttribute(.foregroundColor, value: theme.searchBarTextColor, range: range)
            }

            return attributedString
        }

        /// Creates a string containing a short version the http(s) URL.
        ///
        /// - returns: URL's host without `www` component. `nil` if no host present or scheme does not match http(s).
        static func shortURLString(_ url: URL) -> String? {
            
            guard !url.isCustomURLScheme() else {
                return nil
            }

            return url.host?.droppingWwwPrefix()
        }
        
        private static func getDuckPlayerURL(url: URL, showsFullURL: Bool) -> NSAttributedString? {
            if !showsFullURL {
                return NSAttributedString(
                    string: UserText.duckPlayerFeatureName,
                    attributes: [.foregroundColor: ThemeManager.shared.currentTheme.searchBarTextColor])
            } else {
                if let (videoID, _) = url.youtubeVideoParams {
                    return NSAttributedString(
                        string: URL.duckPlayer(videoID).absoluteString,
                        attributes: [.foregroundColor: ThemeManager.shared.currentTheme.searchBarTextColor])
                }
            }
            return nil
        }
    }
}
