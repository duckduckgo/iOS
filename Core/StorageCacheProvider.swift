//
//  StorageCacheProvider.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

public class StorageCacheProvider {
    
    public static let didUpdateStorageCacheNotification = NSNotification.Name(rawValue: "com.duckduckgo.storageCacheProvider.notifications.didUpdate")

    public typealias StorageCacheUpdateProgress = (ContentBlockerRequest.Configuration) -> Void
    public typealias StorageCacheUpdateCompletion = (StorageCache?) -> Void
    
    private static let updateQueue = DispatchQueue(label: "StorageCache update queue", qos: .utility)
    
    private let lock = NSLock()
    
    private var _current = StorageCache()
    public private(set) var current: StorageCache {
        get {
            let current: StorageCache
            lock.lock()
            current = _current
            lock.unlock()
            return current
        }
        set {
            lock.lock()
            self._current = newValue
            lock.unlock()
        }
    }
    
    public init() {}
    
    public func update(progress: StorageCacheUpdateProgress? = nil, completion: @escaping StorageCacheUpdateCompletion) {

        Self.updateQueue.async {
            let loader = ContentBlockerLoader()
            let currentCache = self.current
            
            guard loader.checkForUpdates(progress: progress) else {
                completion(nil)
                return
            }
            
            let newCache = StorageCache(tld: currentCache.tld,
                                        termsOfServiceStore: currentCache.termsOfServiceStore)
            loader.applyUpdate(to: newCache)
            
            self.current = newCache
            
            NotificationCenter.default.post(name: StorageCacheProvider.didUpdateStorageCacheNotification,
                                            object: self)
            
            completion(newCache)
        }
    }
}
