//
//  Tracker.swift
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

public class Tracker: NSObject {

    public enum Category: String {
        case analytics = "Analytics"
        case advertising = "Advertising"
        case social = "Social"
        case disconnect = "Disconnect"
        case content = "Content"

        static let banned: [Category] = [.analytics, .advertising, .social]
        static let allowed: [Category] = [.disconnect, .content]
        static let all: [Category] = banned + allowed
    }
    
    public let url: String
    public let parentDomain: String?
    public let category: Category?

    public init(url: String, parentDomain: String?, category: Category? = nil) {
        self.url = url
        self.parentDomain = parentDomain
        self.category = category
    }

    public override func isEqual(_ other: Any?) -> Bool {
        guard let other = other as? Tracker else { return false }
        return url == other.url && parentDomain == other.parentDomain && category == other.category
    }
    
    public override var hashValue: Int {
        return url.hashValue ^ (parentDomain?.hashValue ?? 0) ^ (category?.hashValue ?? 0)
    }
    
    public var isIpTracker: Bool {
        if let host = URL(string: url)?.host {
            return URL.isValidIpHost(host)
        }
        return false
    }
    
    var fromMajorNetwork: Bool {
        guard let parentDomain = parentDomain else {
            return false
        }
        return !MajorTrackerNetwork.all.filter( {$0.domain == parentDomain } ).isEmpty
    }
}


extension Dictionary where Key: ExpressibleByStringLiteral, Value: Tracker {
    
    func filter(byCategory categoryFilter: [Tracker.Category]) -> [Key: Value] {
        let filterd = filter { element -> Bool in
            guard let category = element.value.category else { return false }
            return categoryFilter.contains(category)
        }
        return filterd
    }
}


extension Array where Element: Tracker {
    
    func filter(byCategory categoryFilter: [Tracker.Category]) -> [Element] {
        return filter() {
            guard let category = $0.category else { return false }
            return categoryFilter.contains(category)
        }
    }
}
