//
//  FaviconsCacheType.swift
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

public enum FaviconsCacheType: String {

    static let faviconsFolderName = "Favicons"

    case tabs
    case fireproof

    public func cacheLocation() -> URL? {
        return baseCacheURL()?.appendingPathComponent(Self.faviconsFolderName)
    }

    private func baseCacheURL() -> URL? {
        switch self {
        case .fireproof:
            let groupName = BookmarksDatabase.Constants.bookmarksGroupID
            return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName)

        case .tabs:
            return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        }
    }
}
