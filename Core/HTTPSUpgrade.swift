//
//  HTTPSUpgrade.swift
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

public class HTTPSUpgrade {

    private let persistence: HTTPSUpgradePersistence

    public init(persistence: HTTPSUpgradePersistence = CoreDataHTTPSUpgradePersistence()) {
        self.persistence = persistence
    }

    func upgrade(url: URL) -> URL? {
        guard url.scheme == "http" else { return nil }
        guard let host = url.host else { return nil }
        guard persistence.hasDomain(host) else { return nil }
        let urlString = url.absoluteString
        return URL(string: urlString.replacingOccurrences(of: "http", with: "https", options: .caseInsensitive, range: urlString.range(of: "http")))
    }

}
