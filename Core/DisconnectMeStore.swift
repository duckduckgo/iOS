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
    }

    private lazy var stringCache = ContentBlockerStringCache()

    public init() {
        stringCache = ContentBlockerStringCache()
        loadTrackers()
    }

    private func loadTrackers() {
        do {
            let data = try Data(contentsOf: DisconnectMeStore.persistenceLocation)
            self.trackers = try DisconnectMeTrackersParser().convert(fromJsonData: data)
        } catch {
            Logger.log(items: "error parsing json for disconnect", error)
            self.trackers = [:]
        }
    }
    
    var hasData: Bool {
        return !trackers.isEmpty
    }

    public var trackers: [String: DisconnectMeTracker] = [:]

    var bannedTrackersJson: String {
        if let cached = stringCache.get(named: CacheKeys.disconnectJsonBanned) {
            return cached
        }
        if let json = try? convertToInjectableJson(trackers.filter(byCategory: DisconnectMeTracker.Category.banned)) {
            stringCache.put(name: CacheKeys.disconnectJsonBanned, value: json)
            return json
        }
        return "{}"
    }

    var allowedTrackersJson: String {
        if let cached = stringCache.get(named: CacheKeys.disconnectJsonAllowed) {
            return cached
        }
        if let json = try? convertToInjectableJson(trackers.filter(byCategory: DisconnectMeTracker.Category.allowed)) {
            stringCache.put(name: CacheKeys.disconnectJsonAllowed, value: json)
            return json
        }
        return "{}"
    }

    func persist(data: Data) throws {
        Logger.log(items: "DisconnectMeStore", DisconnectMeStore.persistenceLocation)
        try data.write(to: DisconnectMeStore.persistenceLocation, options: .atomic)
        loadTrackers()
        invalidateCache()
    }

    private func invalidateCache() {
        stringCache.remove(named: CacheKeys.disconnectJsonAllowed)
        stringCache.remove(named: CacheKeys.disconnectJsonBanned)
    }

    private func convertToInjectableJson(_ trackers: [String: DisconnectMeTracker]) throws -> String {
        let simplifiedTrackers = trackers.mapValues({ $0.networkName })
        let json = try JSONSerialization.data(withJSONObject: simplifiedTrackers, options: .prettyPrinted)
        if let jsonString = String(data: json, encoding: .utf8) {
            return jsonString
        }
        return ""
    }

    public static var persistenceLocation: URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ContentBlockerStoreConstants.groupName)
        return path!.appendingPathComponent("disconnectme.json")
    }
    
    public func networkNameAndCategory(forDomain domain: String) -> ( networkName: String?, category: String? ) {
        let lowercasedDomain = domain.lowercased()
        if let tracker = trackers.first(where: { lowercasedDomain == $0.key || lowercasedDomain.hasSuffix(".\($0.key)") })?.value {
            return ( tracker.networkName, tracker.category?.rawValue )
        }
        return ( nil, nil )
    }

}
