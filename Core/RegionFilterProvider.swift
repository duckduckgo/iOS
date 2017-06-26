//
//  RegionFilterProvider.swift
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
