//
//  AppleContentBlockerParser.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 18/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public struct AppleContentBlockerParser {
    
    public init() {}
    
    public func toJsonData(forEntries entries: [ContentBlockerEntry]) -> Data? {
        let jsonArray = toJsonArray(forEntries: entries)
        let data = try! JSONSerialization.data(withJSONObject: jsonArray, options:  [])
        return data
    }

    public func toJsonArray(forEntries entries: [ContentBlockerEntry]) -> [Any] {
        var array = [Any]()
        for entry in entries {
            let jsonEntry = toJsonObject(forEntry: entry)
            array.append(jsonEntry)
        }
        return array
    }
    
    private func toJsonObject(forEntry entry: ContentBlockerEntry) -> [String: Any] {
        
        let domain = "*\(entry.domain)"
        let url = "\(entry.url)"
        
        return [
            "action": [
                "type": "block"
            ],
            "trigger": [
                "load-type": ["third-party"],
                "url-filter": url,
                "unless-domain": [domain]
                ]
            ]
    }
}
