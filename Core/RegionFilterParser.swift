//
//  RegionFilterParser.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 29/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation


class RegionFilterParser {
        
    func convert(fromJsonData data: Data?) -> [RegionFilter] {
        var regions = [RegionFilter]()
        guard let data = data else { return regions }
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data) else { return regions }
        guard let json = jsonArray as? [[String: String]] else { return regions }
        
        for element in json {
            if let filter = element.keys.first, let name = element[filter] {
                regions.append(RegionFilter(filter: filter, name: name))
            }
        }
        return regions
    }
}
