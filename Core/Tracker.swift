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

public class Tracker: NSObject, NSCoding {
    
    private struct NSCodingKeys {
        static let url = "url"
        static let parentDomain = "parentdomain"
    }
    
    public let url: String
    public let parentDomain: String?

    public init(url: String, parentDomain: String?) {
        self.url = url
        self.parentDomain = parentDomain
    }
    
    public convenience required init?(coder decoder: NSCoder) {
        guard let url = decoder.decodeObject(forKey: NSCodingKeys.url) as? String else { return nil }
        let parentDomain = decoder.decodeObject(forKey: NSCodingKeys.parentDomain) as? String
        self.init(url: url, parentDomain: parentDomain)
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(url, forKey: NSCodingKeys.url)
        coder.encode(parentDomain, forKey: NSCodingKeys.parentDomain)
    }
    
    public override func isEqual(_ other: Any?) -> Bool {
        guard let other = other as? Tracker else { return false }
        return url == other.url && parentDomain == other.parentDomain
    }
    
    public override var hashValue: Int {
        return url.hashValue ^ (parentDomain?.hashValue ?? 0)
    }
}
