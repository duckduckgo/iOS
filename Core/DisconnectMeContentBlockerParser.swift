//
//  DisconnectMeContentBlockerParser.swift
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
