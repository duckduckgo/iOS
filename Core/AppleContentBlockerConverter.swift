//
//  AppleContentBlockerConverter.swift
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

public struct AppleContentBlockerConverter {
    
    public init() {}
    
    public func toJsonData(trackers: [Tracker]) throws -> Data {
        let jsonArray = toJsonArray(trackers: trackers)
        
        guard let data = try? JSONSerialization.data(withJSONObject: jsonArray, options:  []) else {
            throw JsonError.typeMismatch
        }
        
        return data
    }
    
    private func toJsonArray(trackers: [Tracker]) -> [Any] {
        var array = [Any]()
        for tracker in trackers {
            let jsonTracker = toJsonObject(tracker: tracker)
            array.append(jsonTracker)
        }
        return array
    }
    
    private func toJsonObject(tracker: Tracker) -> [String: Any] {
        
        // REGEX: \/\/([A-Za-z0-9\-]*.)HOST(\/.*)?
        let urlFilter = "\\/\\/([A-Za-z0-9\\-]*.)\(tracker.url)(\\/.*)?"
        
        let trigger: [String: Any] = [
            "url-filter": urlFilter,
            "load-type": [ "third-party" ]
        ]
        
        return [
            "action": [
                "type": "block"
            ],
            "trigger": trigger
        ]
    }
}
