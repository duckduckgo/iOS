//
//  ContentBlockerRulesIdentifier.swift
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

public class ContentBlockerRulesIdentifier {
    
    private let tdsEtag: String
    private let tempListEtag: String
    private let unprotectedSitesHash: String
    
    public var stringValue: String {
        return tdsEtag + tempListEtag + unprotectedSitesHash
    }
    
    public struct Difference: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let tdsEtag = Difference(rawValue: 1 << 0)
        public static let tempListEtag = Difference(rawValue: 1 << 1)
        public static let unprotectedSites = Difference(rawValue: 1 << 2)
        
        public static let all: Difference = [.tdsEtag, .tempListEtag, .unprotectedSites]
    }
    
    private class func normalize(etag: String?) -> String {
        // Ensure etag is in double quotes
        guard var etag = etag else {
            return "\"\""
        }
        
        if !etag.hasSuffix("\"") {
            etag += "\""
        }
        
        if !etag.hasPrefix("\"") {
            etag = "\"" + etag
        }
        
        return etag
    }
    
    public class func hash(domains: [String]?) -> String {
        guard let domains = domains, !domains.isEmpty else {
            return ""
        }
        
        return domains.joined().sha1
    }
    
    init?(identifier: String) {
        guard let betweenEtags = identifier.range(of: "\"\""), let lastEtagChar = identifier.lastIndex(of: "\"") else {
            // Error?
            return nil
        }
        
        tdsEtag = String(identifier[identifier.startIndex...betweenEtags.lowerBound])
        tempListEtag = String(identifier[identifier.index(before: betweenEtags.upperBound)...lastEtagChar])
        unprotectedSitesHash = String(identifier[identifier.index(after: lastEtagChar)..<identifier.endIndex])
    }
    
    init(tdsEtag: String, tempListEtag: String?, unprotectedSites: [String]?) {
        
        self.tdsEtag = Self.normalize(etag: tdsEtag)
        self.tempListEtag = Self.normalize(etag: tempListEtag)
        self.unprotectedSitesHash = Self.hash(domains: unprotectedSites)
    }
    
    public func compare(with id: ContentBlockerRulesIdentifier) -> Difference {
        
        var result = Difference()
        if tdsEtag != id.tdsEtag {
            result.insert(.tdsEtag)
        }
        if tempListEtag != id.tempListEtag {
            result.insert(.tempListEtag)
        }
        if unprotectedSitesHash != id.unprotectedSitesHash {
            result.insert(.unprotectedSites)
        }
        
        return result
    }
}
