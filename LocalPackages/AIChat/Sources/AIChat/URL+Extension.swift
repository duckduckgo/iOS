//
//  URL+Extension.swift
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

extension URL {

    private enum DuckDuckGo {
        static let host = "duckduckgo.com"
        static let chatQueryName = "ia"
        static let chatQueryValue = "chat"
        static let bangQueryName = "q"
        static let supportedBangs: Set<String> = ["ai", "aichat", "chat", "duckai"]
    }

    /**
     Returns a new URL with the given query item added or replaced.  If the query item's value
     is nil or empty after trimming whitespace, the original URL is returned.

     - Parameter queryItem: The query item to add or replace.
     - Returns: A new URL with the query item added or replaced, or the original URL if the query item's value is invalid.
     */
    func addingOrReplacing(_ queryItem: URLQueryItem) -> URL {
        guard let queryValue = queryItem.value,
              !queryValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return self
        }

        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)

        var queryItems = components?.queryItems ?? []
        queryItems.removeAll { $0.name == queryItem.name }
        queryItems.append(queryItem)
        components?.queryItems = queryItems

        return components?.url ?? self
    }

    /**
     Returns `true` if the URL is a DuckDuckGo URL for Duck.ai

     This property checks if the URL's host is `duckduckgo.com` and if it either contains the Duck.ai chat query parameter
     or is a Duck.ai bang.

     - Returns: `true` if the URL is a DuckDuckGo URL for DuckAssist (chat), `false` otherwise.
     */
    public var isDuckAIURL: Bool {
        guard host == DuckDuckGo.host else { return false }
        return isDuckAIChatQuery || isDuckAIBang
    }


    // MARK: - Private methods

    private var isDuckAIChatQuery: Bool {
        return queryItems?.contains { $0.name == DuckDuckGo.chatQueryName && $0.value == DuckDuckGo.chatQueryValue } == true
    }

    var isDuckAIBang: Bool {
        guard host == DuckDuckGo.host else { return false }
        return queryItems?.contains { $0.name == DuckDuckGo.bangQueryName && isSupportedBang(value: $0.value) } == true
    }

    private var queryItems: [URLQueryItem]? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems
    }

    private func isSupportedBang(value: String?) -> Bool {
        guard let value = value else { return false }

        let bangValues = DuckDuckGo.supportedBangs.flatMap { bang in
            ["!\(bang)", "\(bang)!"]
        }

        return bangValues.contains { value.hasPrefix($0) }
    }
}
