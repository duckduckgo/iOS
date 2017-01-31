//
//  AppUrls.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

struct AppUrls {

    static let duckDuckGoBase = "duckduckgo.com"
    
    static let home = "https://www.duckduckgo.com?ko=-1&kl=wt-wt"
    
    static func search(text: String) -> URL? {
        guard let encodedQuery = URL.encode(queryText: text) else {
            return nil
        }
        let url = "\(home)&q=\(encodedQuery)"
        return URL(string: url)
    }
    
    static func isDuckDuckGo(url: URL) -> Bool {
        return url.absoluteString.contains(duckDuckGoBase)
    }
}
