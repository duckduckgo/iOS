//
//  SurrogateStore.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

// TODO delete surrogates.js
class SurrogateStore {

    private let groupIdentifier: String

    public var contentsAsString: String? {
        return try? String(contentsOf: persistenceLocation(), encoding: .utf8)
    }

    init(groupIdentifier: String = ContentBlockerStoreConstants.groupName) {
        self.groupIdentifier = groupIdentifier
    }

    @discardableResult
    func persist(data: Data) -> Bool {
        do {
            try data.write(to: persistenceLocation())
            return true
        } catch {
            return false
        }
    }

    private func persistenceLocation() -> URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        return path!.appendingPathComponent("surrogates.txt")
    }

}
