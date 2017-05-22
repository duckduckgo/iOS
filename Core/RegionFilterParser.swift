//
//  RegionFilterParser.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 29/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

class RegionFilterParser {
    
    func convert(fromJsonData data: Data) throws -> [RegionFilter] {

        guard let jsonArray = try? JSONSerialization.jsonObject(with: data) else {
            throw JsonError.invalidJson
        }
        
        guard let json = jsonArray as? [[String: String]] else {
            throw JsonError.typeMismatch
        }
        
        var regions = [RegionFilter]()
        for element in json {
            let regionFilter = try convert(fromElement: element)
            regions.append(regionFilter)
        }
        return regions
    }
    
    private func convert(fromElement element: [String: String]) throws -> RegionFilter {
        guard let filter = element.keys.first, let name = element[filter] else {
            throw JsonError.typeMismatch
        }
        return RegionFilter(filter: filter, name: name)
    }
}
