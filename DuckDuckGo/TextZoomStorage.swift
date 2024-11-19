//
//  TextZoomStorage.swift
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
import Core
import Common

protocol TextZoomStoring {
    func textZoomLevelForDomain(_ domain: String) -> TextZoomLevel?
    func set(textZoomLevel: TextZoomLevel, forDomain domain: String)
    func removeTextZoomLevel(forDomain domain: String)
    func resetTextZoomLevels(excludingDomains: [String])
}

class TextZoomStorage: TextZoomStoring {

    @UserDefaultsWrapper(key: .domainTextZoomStorage, defaultValue: [:])
    var textZoomLevels: [String: Int]

    func textZoomLevelForDomain(_ domain: String) -> TextZoomLevel? {
        guard let zoomLevel = textZoomLevels[domain] else {
            return nil
        }
        return TextZoomLevel(rawValue: zoomLevel)
    }
    
    func set(textZoomLevel: TextZoomLevel, forDomain domain: String) {
        textZoomLevels[domain] = textZoomLevel.rawValue
    }

    func removeTextZoomLevel(forDomain domain: String) {
        textZoomLevels.removeValue(forKey: domain)
    }

    func resetTextZoomLevels(excludingDomains: [String]) {
        let tld = TLD()
        textZoomLevels = textZoomLevels.filter { level in
            excludingDomains.contains(where: {
                tld.eTLDplus1($0) == level.key
            })
        }
    }

}
