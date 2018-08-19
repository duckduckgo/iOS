//
//  HTTPSUpgradeParser.swift
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

public class HTTPSUpgradeParser {

    static func whitelist(fromJSONData data: Data) -> [String]? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        guard let jsonObject = json as? [String: Any] else { return nil }
        guard let domains = jsonObject["data"] as? [String] else { return nil }
        return domains
    }
    
    static func bloomFilterSpecification(fromJSONData data: Data) -> HTTPSTransientBloomFilterSpecification? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        guard let jsonObject = json as? [String: Any] else { return nil }
        guard let totalEntries = jsonObject["totalEntries"] as? Int else { return nil }
        guard let errorRate = jsonObject["errorRate"] as? Double else { return nil }
        guard let sha256 = jsonObject["sha256"] as? String else { return nil }
        return HTTPSTransientBloomFilterSpecification(totalEntries: totalEntries, errorRate: errorRate, sha256: sha256)
    }
}
