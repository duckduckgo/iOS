//
//  PageZoomStorage.swift
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

protocol PageZoomStoring {
    func zoomLevelForDomain(_ domain: String) -> Int?
    func set(zoomLevel: Int, forDomain domain: String)
    func resetZoomLevels(_ excludingDomains: [String])
}

class PageZoomStorage: PageZoomStoring {

    var zoomLevels: [String: Int] = [:]

    func zoomLevelForDomain(_ domain: String) -> Int? {
        return zoomLevels[domain]
    }
    
    func set(zoomLevel: Int, forDomain domain: String) {
        zoomLevels[domain] = zoomLevel
    }

    func resetZoomLevels(_ excludingDomains: [String]) {
        zoomLevels = zoomLevels.filter {
            !excludingDomains.contains($0.key)
        }
    }

}
