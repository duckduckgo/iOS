//
//  DataStoreIdManager.swift
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


import WebKit
import Persistence

/// Supports an existing ID set in previous versions of the app, but moving forward does not allocate an ID.  We have gone back to using the default
///  peristence for the webview storage so that we can fireproof types that don't have an API for accessing their data. (e.g. localStorage)
public protocol DataStoreIdManaging {

    var currentId: UUID? { get }

    func invalidateCurrentId()
}

public class DataStoreIdManager: DataStoreIdManaging {

    enum Constants: String {
        case currentWebContainerId = "com.duckduckgo.ios.webcontainer.id"
    }

    public static let shared = DataStoreIdManager()

    private let store: KeyValueStoring
    init(store: KeyValueStoring = UserDefaults.app) {
        self.store = store
    }

    public var currentId: UUID? {
        guard let uuidString = store.object(forKey: Constants.currentWebContainerId.rawValue) as? String else {
            return nil
        }
        return UUID(uuidString: uuidString)
    }

    public func invalidateCurrentId() {
        store.removeObject(forKey: Constants.currentWebContainerId.rawValue)
    }

}
