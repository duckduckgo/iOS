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
    
   enum Category: String {
        case advertising = "Advertising"
        case analytics = "Analytics"
        case disconnect = "Disconnect"
        case social = "Social"
        case content = "Content"
    }
    
    func convert(fromJsonData data: Data) throws -> [Tracker] {
        guard let json = try? JSON(data: data) else {
            throw JsonError.invalidJson
        }
        
        let jsonCategories = json["categories"]
        var trackers = [Tracker]()
        for (categoryName, jsonTrackers) in jsonCategories {
            guard isSupported(categoryName: categoryName) else { continue }
            try trackers.append(contentsOf: parseCategory(fromJson: jsonTrackers))
        }
        return trackers
    }
    
    private func parseCategory(fromJson jsonTrackers: JSON) throws -> [Tracker] {
        var trackers = [Tracker]()
        for jsonTracker in jsonTrackers.arrayValue {
            guard let baseUrl = jsonTracker.first?.1.first?.0 else { throw JsonError.typeMismatch }
            guard let jsonTrackers = jsonTracker.first?.1.first?.1.arrayObject else { throw JsonError.typeMismatch }
            let parentDomain = parseDomain(fromUrl: baseUrl)
            let newTrackers = jsonTrackers.map { Tracker(url: "\($0)", parentDomain: parentDomain) }
            trackers.append(contentsOf: newTrackers)
        }
        return trackers
    }
    
    private func parseDomain(fromUrl url: String) -> String? {
        guard let host = URL(string: url)?.host else {
            return nil
        }
        return host.replacingOccurrences(of: "www.", with: "")
    }
    
    func isSupported(categoryName: String) -> Bool {
        guard let category = Category.init(rawValue: categoryName) else { return false }
        return category == .advertising || category == .analytics || category == .social
    }
}
