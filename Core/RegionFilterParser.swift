//
//  RegionFilterParser.swift
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
