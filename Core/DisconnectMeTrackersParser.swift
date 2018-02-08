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

public struct DisconnectMeTrackersParser {
    
    func convert(fromJsonData data: Data) throws -> [String: DisconnectMeTracker] {
        
        guard let anyJson = try? JSONSerialization.jsonObject(with: data) else {
            throw JsonError.invalidJson
        }
        
        guard let json = anyJson as? [String: Any] else {
            throw JsonError.invalidJson
        }
        
        guard let jsonCategories = json["categories"] as? [String: [Any]] else {
            throw JsonError.invalidJson
        }
        
        var trackers = [String: DisconnectMeTracker]()
        for (categoryName, jsonTrackers) in jsonCategories {
            try parse(categoryName: categoryName, fromJson: jsonTrackers, into: &trackers)
        }
        return trackers
    }
    
    private func parse(categoryName: String, fromJson jsonTrackers: [Any], into trackers: inout [String: DisconnectMeTracker]) throws {
        let category = DisconnectMeTracker.Category.all.filter( { $0.rawValue == categoryName }).first

        for jsonTracker in jsonTrackers {
            
            guard let tracker = jsonTracker as? [String: Any] else { throw JsonError.invalidJson }
            guard let networkName = tracker.keys.first else { throw JsonError.typeMismatch }
            guard let network = tracker[networkName] as? [String: Any] else { throw JsonError.typeMismatch }
            guard let baseUrl = baseUrl(fromNetwork: network) else { throw JsonError.typeMismatch }
            guard let parentDomain = parseDomain(fromUrl: baseUrl) else { throw JsonError.typeMismatch }
            guard let urls = network[baseUrl] as? [String] else { throw JsonError.typeMismatch }
            
            trackers[parentDomain] = DisconnectMeTracker(url: parentDomain, networkName: networkName, category: category)
            for url in urls {
                trackers[url] = DisconnectMeTracker(url: url, networkName: networkName, parentUrl: URL(string: baseUrl), category: category)
            }

        }
    }
    
    private func baseUrl(fromNetwork network: [String: Any]) -> String? {
        if let baseUrl = network.keys.first, baseUrl != "dnt" { return baseUrl }
        return network.keys.dropFirst().first
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

