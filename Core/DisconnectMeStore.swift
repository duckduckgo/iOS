//
//  DisconnectMeStore.swift
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

public class DisconnectMeStore {
    
    struct CacheKeys {
        static let disconnectJsonBanned = "disconnect-json-banned"
        static let disconnectJsonAllowed = "disconnect-json-allowed"
        static let disconnectAppleRules = "disconnect-apple-rules"
    }
    
    private lazy var stringCache = ContentBlockerStringCache()
    
    public init() {
        stringCache = ContentBlockerStringCache()
    }
    
    var hasData: Bool {
        get {
            return (try? persistenceLocation.checkResourceIsReachable()) ?? false
        }
    }
    
    public var trackers: [String: Tracker] {
       guard let data = try? Data(contentsOf: persistenceLocation), let trackers = try? parse(data: data) else {
            return [String: Tracker]()
        }
        return trackers
    }
    
    var bannedTrackersJson: String {
        if let cached = stringCache.get(named: CacheKeys.disconnectJsonBanned) {
            return cached
        }
        if let json = try? convertToInjectableJson(trackers.filter(byCategory: Tracker.Category.banned)) {
            stringCache.put(name: CacheKeys.disconnectJsonBanned, value: json)
            return json
        }
        return "{}"
    }
    
    var allowedTrackersJson: String {
        if let cached = stringCache.get(named: CacheKeys.disconnectJsonAllowed) {
            return cached
        }
        if let json = try? convertToInjectableJson(trackers.filter(byCategory: Tracker.Category.banned)) {
            stringCache.put(name: CacheKeys.disconnectJsonAllowed, value: json)
            return json
        }
        return "{}"
    }
    
    var appleRulesJson: String? {
        if let cached = stringCache.get(named: CacheKeys.disconnectAppleRules) {
            return cached
        }
        
        let parser = AppleContentBlockerParser()
        let bannedTrackers = Array(trackers.filter(byCategory: Tracker.Category.banned).values)
        if let ruleData = try? parser.toJsonData(trackers: bannedTrackers), let rulesString = String(bytes: ruleData, encoding: .utf8) {
            stringCache.put(name: CacheKeys.disconnectAppleRules, value: rulesString)
            return rulesString
        }
        return nil
    }
    
    func persist(data: Data) throws  {
        Logger.log(items: "DisconnectMeStore", persistenceLocation)
        try data.write(to: persistenceLocation, options: .atomic)
        invalidateCahce()
    }
    
    private func invalidateCahce() {
        stringCache.remove(named: CacheKeys.disconnectJsonAllowed)
        stringCache.remove(named: CacheKeys.disconnectJsonBanned)
        stringCache.remove(named: CacheKeys.disconnectAppleRules)
    }
    
    private func parse(data: Data) throws -> [String: Tracker] {
        let parser = DisconnectMeTrackersParser()
        return try parser.convert(fromJsonData: data)
    }
    
    private func convertToInjectableJson(_ trackers: [String: Tracker]) throws -> String {
        let simplifiedTrackers = trackers.mapValues( { $0.parentDomain } )
        let json = try JSONSerialization.data(withJSONObject: simplifiedTrackers, options: .prettyPrinted)
        if let jsonString = String(data: json, encoding: .utf8) {
            return jsonString
        }
        return ""
    }
    
    public var persistenceLocation: URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ContentBlockerStoreConstants.groupName)
        return path!.appendingPathComponent("disconnectme.json")
    }
}

