//
//  EntityMappingStore.swift
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

public protocol EntityMappingStore {
    
    func load() -> Data?
    
    func persist(data: Data) -> Bool
    
}

public class DownloadedEntityMappingStore: EntityMappingStore {
    
    static let filename = "entitylist2.json"
    
    public init() { }
    
    public func load() -> Data? {
        return try? Data(contentsOf: persistenceLocation())
    }
    
    public func persist(data: Data) -> Bool {
        do {
            try data.write(to: persistenceLocation(), options: .atomic)
            return true
        } catch {
            Logger.log(items: error)
            return false
        }
    }
    
    private func persistenceLocation() -> URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ContentBlockerStoreConstants.groupName)
        return path!.appendingPathComponent(DownloadedEntityMappingStore.filename)
    }

}
