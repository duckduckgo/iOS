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
        case analytics = "Analytics"
        case advertising = "Advertising"
        case social = "Social"
        case disconnect = "Disconnect"
        case content = "Content"
    }
    
    static let bannedCategoryFilter: [Category] = [.analytics, .advertising, .social]
    static let allowedCategoryFilter: [Category] = [ .disconnect, .content ]

    func convert(fromJsonData data: Data, categoryFilter: [Category]?) throws -> [String: String] {
        guard let json = try? JSON(data: data) else {
            throw JsonError.invalidJson
        }
        
        let jsonCategories = json["categories"]
        var trackers = [String: String]()
        for (categoryName, jsonTrackers) in jsonCategories {
            guard categoryFilter == nil || category(name: categoryName, isIn: categoryFilter!) else { continue }
            try parseCategory(fromJson: jsonTrackers, into: &trackers)
        }
        return trackers
    }
    
    private func parseCategory(fromJson jsonTrackers: JSON, into trackers: inout [String: String]) throws {
        for jsonTracker in jsonTrackers.arrayValue {
            guard let baseUrl = jsonTracker.first?.1.first?.0 else { throw JsonError.typeMismatch }
            guard let jsonTrackers = jsonTracker.first?.1.first?.1.arrayObject else { throw JsonError.typeMismatch }
            let parentDomain = parseDomain(fromUrl: baseUrl)
            for url in jsonTrackers {
                if let url = url as? String {
                    trackers[url] = parentDomain
                }
            }
        }
    }
    
    private func parseDomain(fromUrl url: String) -> String? {
        guard let host = URL(string: url)?.host else {
            return nil
        }
        return host.replacingOccurrences(of: "www.", with: "")
    }
    
    func category(name: String, isIn categories: [Category]) -> Bool {
        guard let category = Category(rawValue: name) else { return false }
        return categories.filter({ $0 == category }).first != nil
    }
}

