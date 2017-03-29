//
//  AppDeepLinks.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 29/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public struct AppDeepLinks {
    
    public static let launch = "ddgLaunch://"
    
    public static let quickLink = "ddgQuickLink://"
    
    public static func isLaunch(url: URL) -> Bool {
        if let scheme = url.scheme {
            return AppDeepLinks.launch.contains(scheme)
        }
        return false
    }
    
    public static func isQuickLink(url: URL) -> Bool {
        if let scheme = url.scheme {
            return AppDeepLinks.quickLink.contains(scheme)
        }
        return false
    }
}
