//
//  DisconnectMeTrackersParser.swift
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
import SwiftyJSON


public struct DisconnectMeTrackersParser {
    
    func convert(fromJsonData data: Data) throws -> [String: Tracker] {
        guard let json = try? JSON(data: data) else {
            throw JsonError.invalidJson
        }
        
        let jsonCategories = json["categories"]
        var trackers = [String: Tracker]()
        for (categoryName, jsonTrackers) in jsonCategories {
            try parse(categoryName: categoryName, fromJson: jsonTrackers, into: &trackers)
        }
        return trackers
    }
    
    private func parse(categoryName: String, fromJson jsonTrackers: JSON, into trackers: inout [String: Tracker]) throws {
        for jsonTracker in jsonTrackers.arrayValue {
            
            guard let networkName = jsonTracker.first?.0 else { throw JsonError.typeMismatch }
            guard let jsonTrackers = jsonTracker.first?.1.first(where: { $0.1.arrayObject != nil } )?.1.arrayObject else { throw JsonError.typeMismatch }

            let category = Tracker.Category.all.filter( { $0.rawValue == categoryName }).first

            guard let baseUrl = jsonTracker.first?.1.first?.0 else { throw JsonError.typeMismatch }
            guard let parentDomain = parseDomain(fromUrl: baseUrl) else { throw JsonError.typeMismatch }

            trackers[parentDomain] = Tracker(url: parentDomain, networkName: networkName, category: category)

            for url in jsonTrackers {
                guard let url = url as? String else { continue }
                trackers[url] = Tracker(url: url, networkName: networkName, category: category)
            }
        }
    }
    
    private func parseDomain(fromUrl url: String) -> String? {
        var urlToConvert = url
        if !url.starts(with: "http") {
            urlToConvert = "http://\(url)"
        }

        guard let host = URL(string: urlToConvert)?.host else {
            return nil
        }
        return host.replacingOccurrences(of: "www.", with: "")
    }

}

