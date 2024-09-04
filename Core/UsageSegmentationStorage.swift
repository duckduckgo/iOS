//
//  UsageSegmentationStorage.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import Persistence

protocol UsageSegmentationStoring {

    var searchAtbs: [Atb] { get set }
    var appUseAtbs: [Atb] { get set }

}

final class UsageSegmentationStorage: UsageSegmentationStoring {

    enum Keys {
        static let search = "usageSegmentation.atbs.search"
        static let appUse = "usageSegmentation.atbs.appUse"
    }

    var searchAtbs: [Atb] {
        get {
            let storedAtbs: [String] = (keyValueStore.object(forKey: Keys.search) as? [String]) ?? []
            return storedAtbs.map {
                Atb(version: $0, updateVersion: nil)
            }
        }

        set {
            keyValueStore.set(newValue.map {
                $0.version
            }, forKey: Keys.search)
        }
    }

    var appUseAtbs: [Atb] {
        get {
            let storedAtbs: [String] = (keyValueStore.object(forKey: Keys.appUse) as? [String]) ?? []
            return storedAtbs.map {
                Atb(version: $0, updateVersion: nil)
            }
        }

        set {
            keyValueStore.set(newValue.map {
                $0.version
            }, forKey: Keys.appUse)
        }
    }

    let keyValueStore: KeyValueStoring

    init(keyValueStore: KeyValueStoring = UserDefaults.app) {
        self.keyValueStore = keyValueStore
    }

}
