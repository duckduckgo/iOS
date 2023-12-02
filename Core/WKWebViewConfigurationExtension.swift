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

extension WKWebViewConfiguration {


    public static func persistent(idManager: DataStoreIdManager = .shared) -> WKWebViewConfiguration {
        let config = configuration(persistsData: true)
        if #available(iOS 17, *) {
            config.websiteDataStore = WKWebsiteDataStore(forIdentifier: idManager.id)
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

public class DataStoreIdManager {

    public static let shared = DataStoreIdManager()

    @UserDefaultsWrapper(key: .webContainerId, defaultValue: nil)
    private var containerId: String?

    var id: UUID {
        if containerId == nil {
            containerId = UUID().uuidString
        }

        if let containerId,
           let uuid = UUID(uuidString: containerId) {
            print("***", containerId)
            return uuid
        }

        fatalError("Unable to create container ID")
    }

    var hasId: Bool {
        return containerId != nil
    }

    public func reset() {
        self.containerId = nil
    }

}
