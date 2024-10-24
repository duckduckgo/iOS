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
    func textZoomLevelForDomain(_ domain: String) -> TextZoomLevel?
    func set(textZoomLevel: TextZoomLevel, forDomain domain: String)
    func resetTextZoomLevels(_ excludingDomains: [String])
}

class PageZoomStorage: PageZoomStoring {

    // TODO persist this
    var textZoomLevels: [String: Int] = [:]

    func textZoomLevelForDomain(_ domain: String) -> TextZoomLevel? {
        guard let zoomLevel = textZoomLevels[domain] else {
            return nil
        }
        return TextZoomLevel(rawValue: zoomLevel)
    }
    
    func set(textZoomLevel: TextZoomLevel, forDomain domain: String) {
        textZoomLevels[domain] = textZoomLevel.rawValue
    }

    func resetTextZoomLevels(_ excludingDomains: [String]) {
        textZoomLevels = textZoomLevels.filter {
            !excludingDomains.contains($0.key)
        }
    }

}
