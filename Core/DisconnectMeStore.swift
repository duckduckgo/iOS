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

class DisconnectMeStore {

    static let shared = DisconnectMeStore()

    var hasData: Bool {
        return !allTrackers.isEmpty
    }

    private(set) var allTrackers = [String: String]()
    private(set) var bannedTrackersJson = "[]"
    
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
        allTrackers = try parser.convert(fromJsonData: data, categoryFilter: nil)
        
        let bannedTrackers = try parser.convert(fromJsonData: data, categoryFilter: DisconnectMeTrackersParser.bannedCategoryFilter)
        let json = try JSONSerialization.data(withJSONObject: bannedTrackers, options: .prettyPrinted)
        if let jsonString = String(data: json, encoding: .utf8) {
            bannedTrackersJson = jsonString
        }
    }
    
    private func persistenceLocation() -> URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ContentBlockerStoreConstants.groupName)
        return path!.appendingPathComponent("disconnectme.json")
    }
}
