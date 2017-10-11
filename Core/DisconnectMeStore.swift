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

    public static let shared = DisconnectMeStore()

    var hasData: Bool {
        return !trackers.isEmpty
    }

    public private(set) var trackers = [String: Tracker]()
    public private(set) var bannedTrackersJson = "{}"
    public private(set) var allowedTrackersJson = "{}"

    private init() {
        try? load(data: Data(contentsOf: persistenceLocation()))
    }
    
    func persist(data: Data) throws  {
        try load(data: data)

        let location = persistenceLocation()
        Logger.log(items: "DisconnectMeStore", location)
        try data.write(to: persistenceLocation(), options: .atomic)
    }

    private func load(data: Data) throws {
        let parser = DisconnectMeTrackersParser()
        trackers = try parser.convert(fromJsonData: data)
        bannedTrackersJson = (try? convertToInjectableJson(trackers, filterBy: Tracker.Category.banned)) ?? "{}"
        allowedTrackersJson = (try? convertToInjectableJson(trackers, filterBy: Tracker.Category.allowed)) ?? "{}"
    }

    private func convertToInjectableJson(_ trackers: [String: Tracker], filterBy categoryFilter: [Tracker.Category]) throws -> String {
        let filterdTrackers = trackers.filter { element -> Bool in
            guard let category = element.value.category else { return false }
            return categoryFilter.contains(category)
        }
        let simplifiedFilteredTrackers = filterdTrackers.mapValues( { $0.parentDomain } )
        
        let json = try JSONSerialization.data(withJSONObject: simplifiedFilteredTrackers, options: .prettyPrinted)
        if let jsonString = String(data: json, encoding: .utf8) {
            return jsonString
        }
        return ""
    }

    private func persistenceLocation() -> URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ContentBlockerStoreConstants.groupName)
        return path!.appendingPathComponent("disconnectme.json")
    }
}
