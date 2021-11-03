//
//  LinkCleaner.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

public class LinkCleaner {
    
    public static let shared = LinkCleaner()
    
    private let ampFormats = [
        "https?:\\/\\/(?:w{3}\\.)?google\\.com\\/amp\\/s\\/(.+)",
        "https?:\\/\\/.+ampproject\\.org\\/v\\/s\\/(.+)"
    ]
    
    public func urlIsExtractableAmpLink(_ url: URL) -> String? {
        for format in ampFormats {
            if url.absoluteString.matches(pattern: format) {
                return format
            }
        }
        
        return nil
    }
    
    public func extractCanonicalFromAmpLink(_ url: URL?) -> URL? {
        guard let url = url else { return nil }
        guard let ampFormat = urlIsExtractableAmpLink(url) else { return nil }
        
        do {
            let regex = try NSRegularExpression(pattern: ampFormat, options: [.caseInsensitive])
            let matches = regex.matches(in: url.absoluteString,
                                        options: [],
                                        range: NSRange(url.absoluteString.startIndex..<url.absoluteString.endIndex,
                                                       in: url.absoluteString))
            guard let match = matches.first else { return nil }
            
            let matchRange = match.range(at: 1)
            if let substrRange = Range(matchRange, in: url.absoluteString) {
                var urlStr = String(url.absoluteString[substrRange])
                if !urlStr.hasPrefix("http") {
                    urlStr = "https://\(urlStr)"
                    return URL(string: urlStr)
                }
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
}
