//
//  ContentBlockerStringCache.swift
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

public class ContentBlockerStringCache {

    struct Constants {
        // bump the cache version if you know the cache should be invalidated on the next release
        static let cacheVersion = 2
        static let cacheVersionKey = "com.duckduckgo.contentblockerstringcache.version"
    }

    private var cacheDir: URL {
        get {
            let groupName = ContentBlockerStoreConstants.groupName
            return fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupName)!.appendingPathComponent("string-cache")
        }
    }

    private var fileManager: FileManager {
        get {
            return FileManager.default
        }
    }

    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        let lastSeenVersion = userDefaults.integer(forKey: Constants.cacheVersionKey)
        if lastSeenVersion < Constants.cacheVersion {
            clearCache()
            userDefaults.set(Constants.cacheVersion, forKey: Constants.cacheVersionKey)
        }
    }

    private func clearCache() {
        try? fileManager.removeItem(atPath: cacheDir.path)
    }

    public func get(named name: String) -> String? {
        return try? String(contentsOf: persistenceLocation(for: name), encoding: .utf8)
    }

    public func put(name: String, value: String) {
        try? value.write(to: persistenceLocation(for: name), atomically: true, encoding: .utf8)
    }

    public func remove(named name: String) {
        try? fileManager.removeItem(at: persistenceLocation(for: name))
    }

    private func persistenceLocation(for name: String) -> URL {
        try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true, attributes: nil)
        let location = cacheDir.appendingPathComponent(name)
        return location
    }

}
