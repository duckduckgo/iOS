//
//  DisconnectMeContentBlockerParser.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 18/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public struct DisconnectMeContentBlockerParser {
    
    func convert(fromJsonData data: Data) throws -> CategorizedContentBlockerEntries {
        guard let json = try? JSON(data: data) else {
            throw JsonError.invalidJson
        }
        
        let jsonCategories = json["categories"]
        var categorizedEntries = CategorizedContentBlockerEntries()
        for (category, jsonEntries) in jsonCategories {
            try categorizedEntries[category] = parseCategory(category, fromJson: jsonEntries)
        }
        return categorizedEntries
    }
    
    private func parseCategory(_ category: String, fromJson jsonEntries: JSON) throws -> [ContentBlockerEntry] {
        var entries = [ContentBlockerEntry]()
        let category = ContentBlockerCategory.forKey(category)
        for jsonEntry in jsonEntries.arrayValue {
            guard let baseUrl = jsonEntry.first?.1.first?.0 else { throw JsonError.typeMismatch }
            guard let jsonTrackers = jsonEntry.first?.1.first?.1.arrayObject else { throw JsonError.typeMismatch }
            let domain = parseDomain(fromUrl: baseUrl)
            let newEntries = jsonTrackers.map({ ContentBlockerEntry(category: category, domain: domain, url: "\($0)") })
            entries.append(contentsOf: newEntries)
        }
        return entries
    }
    
    private func parseDomain(fromUrl url: String) -> String {
        let host = URL(string: url)?.host ?? url
        return host.replacingOccurrences(of: "www.", with: "")
    }
}
