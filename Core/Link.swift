//
//  Link.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 06/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public final class Link: NSObject, NSCoding {
    
    public let title: String
    public let url: URL
    
    private struct NSCodingKeys {
        static let title = "title"
        static let url = "url"
    }
    
    public required init(title: String, url: URL) {
        self.title = title
        self.url = url
    }
    
    public convenience init?(coder aDecoder: NSCoder) {
        guard let title = aDecoder.decodeObject(forKey: NSCodingKeys.title) as? String,
              let url = aDecoder.decodeObject(forKey: NSCodingKeys.url) as? URL else {
            return nil
        }
        self.init(title: title, url: url)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: (NSCodingKeys.title))
        aCoder.encode(url, forKey: (NSCodingKeys.url))
    }
}
