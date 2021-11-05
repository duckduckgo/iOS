//
//  TrackingLinkSettings.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

struct TrackingLinkSettings {
    
    let ampLinkFormats: [String]
    let ampKeywords: [String]
    let trackingParameters: [String]
    
    struct Constants {
        static let ampLinkFormats = "ampLinkFormats"
        static let ampKeywords = "ampKeywords"
        static let trackingParameters = "trackingParameters"
    }
    
    init(fromConfig config: PrivacyConfiguration) {
        guard let feature = config.feature(forKey: .trackingLinks) else {
            ampLinkFormats = []
            ampKeywords = []
            trackingParameters = []
            return
        }
        
        ampLinkFormats = feature.settings[Constants.ampLinkFormats] as? [String] ?? []
        ampKeywords = feature.settings[Constants.ampKeywords] as? [String] ?? []
        trackingParameters = feature.settings[Constants.trackingParameters] as? [String] ?? []
    }
    
}
