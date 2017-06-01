//
//  RegionFilterProvider.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public struct RegionFilterProvider {
    
    private struct FileConstants {
        static let name = "regions"
        static let ext = "json"
    }
    
    public static let defaultRegion = RegionFilter(filter: "wt-wt", name: "None (Default)")
    public let all = RegionFilterProvider.loadRegions()
    
    public init() {}
    
    public func regionForKey(_ key: String?) -> RegionFilter {
        guard let filter = all.filter({ (item) in item.filter == key }).first else {
            return RegionFilterProvider.defaultRegion
        }
        return filter
    }
    
    private static func loadRegions() -> [RegionFilter] {
        do {
            let data = try FileLoader().load(name: FileConstants.name, ext: FileConstants.ext)
            return try RegionFilterParser().convert(fromJsonData: data)
        } catch {
            Logger.log(text: "Could not load regions due to \(error) returning empty regions")
            return [RegionFilter]()
        }
    }
}
