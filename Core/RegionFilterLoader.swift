//
//  RegionFilterLoader.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 29/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation


class RegionFilterLoader {
    
    private static let filename = "regions"
    private static let fileExtension = "json"
    
    func loadRegions() -> [RegionFilter] {
        
        var regions = [RegionFilter]()
        guard let json = getJson() else { return regions }
        
        for element in json {
            if let filter = element.keys.first, let name = element[filter] {
                regions.append(RegionFilter(filter: filter, name: name))
            }
        }
        return regions
    }
    
    private func getJson() -> [[String: String]]? {
        let bundle = Bundle.init(for: RegionFilterLoader.self)
        guard let path = bundle.path(forResource: RegionFilterLoader.filename, ofType: RegionFilterLoader.fileExtension) else { return nil }
        guard let jsonString = try? String(contentsOfFile: path) else { return nil }
        guard let data = jsonString.data(using: .utf16) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }
        return json as? [[String: String]]
    }
}
