//
//  Link.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 06/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public class Link: NSObject, NSCoding {
    
    public let title: String?
    public let url: URL
    public let favicon: URL?
    
    private struct NSCodingKeys {
        static let title = "title"
        static let url = "url"
        static let favicon = "favicon"
    }
    
    public required init(title: String?, url: URL, favicon: URL? = nil) {
        self.title = title
        self.url = url
        self.favicon = favicon
    }
    
    public var hasFavicon: Bool {
        return favicon != nil
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        guard let url = aDecoder.decodeObject(forKey: NSCodingKeys.url) as? URL else { return nil }
        let title = aDecoder.decodeObject(forKey: NSCodingKeys.title) as? String
        let favicon = aDecoder.decodeObject(forKey: NSCodingKeys.favicon) as? URL
        self.init(title: title, url: url, favicon: favicon)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: NSCodingKeys.title)
        aCoder.encode(url, forKey: NSCodingKeys.url)
        aCoder.encode(favicon, forKey: NSCodingKeys.favicon)
    }
}
