//
//  FileStore.swift
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

public class FileStore {
    
    private let groupIdentifier: String

    init(groupIdentifier: String = ContentBlockerStoreConstants.groupName) {
        self.groupIdentifier = groupIdentifier
        removeLegacyData()
    }
    
    /// Remove all legacy data.
    ///
    /// Removes the following files
    /// * surrogates.js
    /// * xxx
    ///
    func removeLegacyData() {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        try? FileManager.default.removeItem(at: path!.appendingPathComponent("surrogates.js"))
    }
    
    func persist(_ data: Data?, forConfiguration config: ContentBlockerRequest.Configuration) -> Bool {
        guard let data = data else { return false }
        do {
            try data.write(to: persistenceLocation(forConfiguration: config))
            return true
        } catch {
            return false
        }
    }
    
    func loadAsString(forConfiguration config: ContentBlockerRequest.Configuration) -> String? {
        return try? String(contentsOf: persistenceLocation(forConfiguration: config))
    }
    
    func persistenceLocation(forConfiguration config: ContentBlockerRequest.Configuration) -> URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        return path!.appendingPathComponent(config.rawValue)
    }

}
