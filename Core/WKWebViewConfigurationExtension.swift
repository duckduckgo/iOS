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
    public static func persistent(idManager: DataStoreIdManaging = DataStoreIdManager.shared) -> WKWebViewConfiguration {
        let config = configuration(persistsData: true)

        // Only use a container if there's an id which will be allocated next time the fire button is used.
        if #available(iOS 17, *), let containerId = idManager.currentId {
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

public protocol DataStoreIdManaging {

    var currentId: UUID? { get }

    var invalidatedIds: [UUID] { get }
    func invalidateCurrentIdAndAllocateNew()

}

public class DataStoreIdManager: DataStoreIdManaging {

    enum Constants: String {
        case currentWebContainerId = "com.duckduckgo.ios.webcontainer.id"
        case invalidatedWebContainerIdList = "com.duckduckgo.ios.webcontainer.invalidated.ids"
    }

    public static let shared = DataStoreIdManager()

    private let lock = NSRecursiveLock()

    private let store: KeyValueStoring
    init(store: KeyValueStoring = UserDefaults.app) {
        self.store = store
    }

    public var currentId: UUID? {
        lock.lock()
        defer { lock.unlock() }
        return store.object(forKey: Constants.currentWebContainerId.rawValue) as? UUID
    }

    public var invalidatedIds: [UUID] {
        lock.lock()
        defer { lock.unlock() }
        return (store.object(forKey: Constants.invalidatedWebContainerIdList.rawValue) as? [UUID]) ?? []
    }

    public func invalidateCurrentIdAndAllocateNew() {
        lock.lock()
        defer { lock.unlock() }

        guard let currentID = currentId else {
            store.set(UUID(), forKey: Constants.currentWebContainerId.rawValue)
            return
        }

        var invalidatedIds = invalidatedIds
        invalidatedIds.append(currentID)

        store.set(UUID(), forKey: Constants.currentWebContainerId.rawValue)
        store.set(invalidatedIds, forKey: Constants.invalidatedWebContainerIdList.rawValue)
    }

}
