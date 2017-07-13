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
    
    public static let launch = "ddgLaunch://"
    
    public static let quickLink = "ddgQuickLink://"
    
    public static let privacyPolicy = URL(string: "\(AppDeepLinks.quickLink)https://duckduckgo.com/privacy")!
    
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
    
    public static func query(fromQuickLink url: URL) -> String {
        return url.absoluteString.replacingOccurrences(of: quickLink, with: "")
    }
}
