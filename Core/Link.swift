//
//  Link.swift
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

public class Link: NSObject, NSCoding {
    
    struct Constants {
        static let ddgSuffix = " at DuckDuckGo"
    }

    private struct NSCodingKeys {
        static let title = "title"
        static let url = "url"
    }
    
    static let appUrls = AppUrls()

    public let title: String?
    public let url: URL
    
    public var displayTitle: String? {
        let host = url.host?.dropPrefix(prefix: "www.") ?? url.absoluteString
        
        var displayTitle = (title?.isEmpty ?? true) ? host : title
        
        if Self.appUrls.isDuckDuckGo(url: url),
            let title = displayTitle, title.hasSuffix(Constants.ddgSuffix) {
            displayTitle = String(title.dropLast(Constants.ddgSuffix.count))
        }
        
        return displayTitle
    }

    public required init(title: String?, url: URL) {
        self.title = title
        self.url = url
    }

    public convenience required init?(coder decoder: NSCoder) {
        guard let url = decoder.decodeObject(forKey: NSCodingKeys.url) as? URL else { return nil }
        let title = decoder.decodeObject(forKey: NSCodingKeys.title) as? String
        self.init(title: title, url: url)
    }

    public func encode(with coder: NSCoder) {
        coder.encode(title, forKey: NSCodingKeys.title)
        coder.encode(url, forKey: NSCodingKeys.url)
    }

    public override func isEqual(_ other: Any?) -> Bool {
        guard let other = other as? Link else { return false }
        return title == other.title && url == other.url
    }

    /**
     Provided links share the same url, uses other to plug any missing data.
     */
    public func merge(with other: Link) -> Link {

        if url != other.url {
            return self
        }

        let mergeTitle = (title == nil || title!.isEmpty) ? other.title : title
        return Link(title: mergeTitle, url: url)
    }
}
