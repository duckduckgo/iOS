//
//  WKWebViewConfigurationExtension.swift
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

import WebKit
import Persistence

extension WKWebViewConfiguration {

    @MainActor
    public static func persistent(idManager: DataStoreIDManaging = DataStoreIDManager.shared) -> WKWebViewConfiguration {
        let config = configuration(persistsData: true)

        // Only use a container if there's an id.  We no longer allocate ids so this should not happen.
        if #available(iOS 17, *), let containerId = idManager.currentID {
            config.websiteDataStore = WKWebsiteDataStore(forIdentifier: containerId)
        }
        return config
    }

    public static func nonPersistent() -> WKWebViewConfiguration {
        return configuration(persistsData: false)
    }

    private static func configuration(persistsData: Bool) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        if !persistsData {
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        }

        // Telephone numbers can be still be interacted with by selecting on them and using the popover menu
        configuration.dataDetectorTypes = []

        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.ignoresViewportScaleLimits = true
        configuration.preferences.isFraudulentWebsiteWarningEnabled = false

        return configuration
    }

}
