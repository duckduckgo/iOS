//
//  AppLastCompiledRulesStore.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit
import TrackerRadarKit

struct AppLastCompiledRules: LastCompiledRules, Codable {

    var name: String
    var trackerData: TrackerData
    var etag: String
    var identifier: ContentBlockerRulesIdentifier

}

protocol Storage {
    func persist(_ data: Data) -> Bool
    var data: Data? { get }
}

struct LastCompiledRulesStorage: Storage {

    private enum Const {
        static let filename = "LastCompiledRules"
        static let path = FileManager
            .default
            .containerURL(forSecurityApplicationGroupIdentifier: ContentBlockerStoreConstants.groupName)!
            .appendingPathComponent(filename)
    }

    func persist(_ data: Data) -> Bool {
        do {
            try data.write(to: Const.path, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    var data: Data? {
        do {
            return try Data(contentsOf: Const.path)
        } catch {
            return nil
        }
    }

}

final class AppLastCompiledRulesStore: LastCompiledRulesStore {

    private var storage: Storage

    init(with storage: Storage = LastCompiledRulesStorage()) {
        self.storage = storage
    }

    var rules: [LastCompiledRules] {
        guard
            let data = storage.data,
            let rules = try? JSONDecoder().decode([AppLastCompiledRules].self, from: data) else {
            return []
        }
        return rules
    }

    func update(with contentBlockerRules: [ContentBlockerRulesManager.Rules]) {
        let rules = contentBlockerRules.map { rules in
            AppLastCompiledRules(name: rules.name,
                                 trackerData: rules.trackerData,
                                 etag: rules.etag,
                                 identifier: rules.identifier)
        }

        if !rules.isEmpty, let encodedRules = try? JSONEncoder().encode(rules) {
            _ = storage.persist(encodedRules)
        }
    }

}
