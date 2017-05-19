//
//  DisconnectMeContentBlockerParser.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 18/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public struct DisconnectMeContentBlockerParser {
    
     func convert(fromJsonData data: Data?) -> CategorizedContentBlockerEntries? {
        guard let data = data, let json = try? JSON(data: data) else { return nil }
        let jsonCategories = json["categories"]
        var categorizedEntries = CategorizedContentBlockerEntries()
        for (category, jsonEntries) in jsonCategories {
            categorizedEntries[category] = parseCategory(fromJson: jsonEntries)
        }
        return categorizedEntries
    }
    
    private func parseCategory(fromJson jsonEntries: JSON) -> [ContentBlockerEntry] {
        var entries = [ContentBlockerEntry]()
        for jsonEntry in jsonEntries.arrayValue {
            guard let baseUrl = jsonEntry.first?.1.first?.0 else { continue }
            let domain = parseDomain(fromUrl: baseUrl)
            guard let jsonTrackers = jsonEntry.first?.1.first?.1.arrayObject else { continue }
            let newEntries = jsonTrackers.map({ ContentBlockerEntry(domain: domain, url: "\($0)") })
            entries.append(contentsOf: newEntries)
        }
        return entries
    }
    
    private func parseDomain(fromUrl url: String) -> String {
        let host = URL(string: url)?.host ?? url
        return host.replacingOccurrences(of: "www.", with: "")
    }
}
