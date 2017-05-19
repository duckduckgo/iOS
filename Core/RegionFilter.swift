//
//  RegionFilter.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 29/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public struct RegionFilter {
        
    private static let allRegions = RegionFilterLoader().load()
    private static let defaultRegion = RegionFilter(filter: "wt-wt", name: "None (Default)")
    
    public let filter: String
    public let name: String
    
    public static func all() -> [RegionFilter] {
        return allRegions
    }
    
    public static func forKey(_ key: String?) -> RegionFilter {
        guard let key = key else { return defaultRegion }
        return allRegions.filter({ (item) in item.filter == key }).first ?? defaultRegion
    }
}
