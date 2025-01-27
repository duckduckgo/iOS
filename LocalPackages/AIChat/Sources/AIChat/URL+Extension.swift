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
    enum Constants {
        static let duckDuckGoHost = "duckduckgo.com"
        static let chatQueryName = "ia"
        static let chatQueryValue = "chat"

        static let bangQueryName = "q"
        static let supportedBangs: Set<String> = ["ai", "aichat", "chat", "duckai"]
    }

    func addingOrReplacingQueryItem(_ queryItem: URLQueryItem) -> URL {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }

        var queryItems = urlComponents.queryItems ?? []
        queryItems.removeAll { $0.name == queryItem.name }
        queryItems.append(queryItem)

        urlComponents.queryItems = queryItems
        return urlComponents.url ?? self
    }

    public var isDuckAIURL: Bool {
        guard let host = self.host, host == Constants.duckDuckGoHost else {
            return false
        }

        guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = urlComponents.queryItems else {
            return false
        }

        return queryItems.contains { $0.name == Constants.chatQueryName && $0.value == Constants.chatQueryValue } || self.isDuckAIBang
    }

    public var isDuckAIBang: Bool {
        guard let host = self.host, host == Constants.duckDuckGoHost else {
            return false
        }

        guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = urlComponents.queryItems else {
            return false
        }

        return queryItems.contains { $0.name == Constants.bangQueryName && hasSupportedBangPrefix($0.value) }
    }

    private func hasSupportedBangPrefix(_ input: String?) -> Bool {
        guard let input = input else {
            return false
        }

        /// Bangs can be used either at the beginning or at the end of a query.
        let bangValues = Constants.supportedBangs.flatMap { bang in
            return ["!\(bang)", "\(bang)!"]
        }
        return bangValues.contains { input.hasPrefix($0) }
    }

}
