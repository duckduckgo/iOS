//
//  DetectedTracker.swift
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

// Populated with relevant info at the point of detection.  If networkName or category are nil, they are genuinely not known.
public struct DetectedTracker {

    public let url: String
    public let blocked: Bool
    public let networkName: String?
    public let category: String?

    public init(url: String, networkName: String?, category: String?, blocked: Bool) {
        self.url = url
        self.networkName = networkName
        self.category = category
        self.blocked = blocked
    }

    public var domain: String? {
        return URL(string: url)?.host
    }

    public var isIpTracker: Bool {
        return URL.isValidIpHost(domain ?? "")
    }
    
    public var networkNameForDisplay: String {
        return networkName ?? domain ?? url
    }

}

extension DetectedTracker: Hashable {

    public func hash( into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(blocked)
        hasher.combine(networkName)
        hasher.combine(category)
    }

    public static func == (lhs: DetectedTracker, rhs: DetectedTracker) -> Bool {
        return lhs.url == rhs.url
            && lhs.blocked == rhs.blocked
            && lhs.networkName == rhs.networkName
            && lhs.category == rhs.category
    }

}
