//
//  AppUrls.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public struct AppUrls {

    public static let launch = "ddgLaunch://"
    
    public static let quickLink = "ddgQuickLink://"

    static let duckDuckGoBase = "duckduckgo.com"

    static let home = "https://www.duckduckgo.com?ko=-1&kl=wt-wt"
    
    static func search(text: String) -> URL? {
        guard let encodedQuery = URL.encode(queryText: text) else {
            return nil
        }
        let url = "\(home)&q=\(encodedQuery)"
        return URL(string: url)
    }
    
    public static func isLaunch(url: URL) -> Bool {
        if let scheme = url.scheme {
            return AppUrls.launch.contains(scheme)
        }
        return false
    }
    
    public static func isQuickLink(url: URL) -> Bool {
        if let scheme = url.scheme {
            return AppUrls.quickLink.contains(scheme)
        }
        return false
    }
    
    public static func isDuckDuckGo(url: URL) -> Bool {
        return url.absoluteString.contains(duckDuckGoBase)
    }
}
