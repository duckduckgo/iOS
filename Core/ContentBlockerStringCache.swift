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
        static let groupName = "group.com.duckduckgo.contentblocker"
    }

    public init() { }

    public func get(named name: String) -> String? {
        return try? String(contentsOf: persistenceLocation(for: name), encoding: .utf8)
    }

    public func put(name: String, value: String) {
        try? value.write(to: persistenceLocation(for: name), atomically: true, encoding: .utf8)
    }

    public func remove(named name: String) {
        try? FileManager.default.removeItem(at: persistenceLocation(for: name))
    }

    private func persistenceLocation(for name: String) -> URL {
        let cacheDir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.groupName)!.appendingPathComponent("string-cache")
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true, attributes: nil)
        return cacheDir.appendingPathComponent(name)
    }

}
