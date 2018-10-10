//
//  DisconnectMeTracker.swift
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

public class DisconnectMeTracker: NSObject {

    public enum Category: String {
        case analytics = "Analytics"
        case advertising = "Advertising"
        case social = "Social"
        case disconnect = "Disconnect"
        case content = "Content"

        static let banned: [Category] = [.analytics, .advertising, .social]
        static let allowed: [Category] = [.disconnect, .content]
        static let all: [Category] = banned + allowed
    }

    public let url: String
    public let networkName: String?
    public let parentUrl: URL?
    public let category: Category?

    public init(url: String, networkName: String?, parentUrl: URL? = nil, category: Category? = nil) {
        self.url = url
        self.networkName = networkName
        self.parentUrl = parentUrl
        self.category = category
    }

    public override func isEqual(_ other: Any?) -> Bool {
        guard let other = other as? DisconnectMeTracker else { return false }
        return url == other.url && networkName == other.networkName && category == other.category
    }

    public override var hash: Int {
        return "\(url) \(String(describing: networkName)) \(String(describing: category))".hash
    }

}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: DisconnectMeTracker {

    func filter(byCategory categoryFilter: [DisconnectMeTracker.Category]) -> [Key: Value] {
        let filtered = filter { element -> Bool in
            guard let category = element.value.category else { return false }
            return categoryFilter.contains(category)
        }
        return filtered
    }
}
