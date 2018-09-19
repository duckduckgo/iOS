//
//  EntityMapping.swift
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

public class EntityMapping {
    
    private struct Entity: Decodable {
        
        let properties: [String]
        let resources: [String]
        
    }
    
    private let entities: [String: String]
    
    public init(store: EntityMappingStore = DownloadedEntityMappingStore()) {
        
        if let data = store.load(), let entities = try? EntityMapping.process(data) {
            self.entities = entities
        } else {
            self.entities = [:]
        }
        
    }
    
    func findEntity(forURL url: URL) -> String? {
        guard let host = url.host else { return nil }
        var parts = host.split(separator: ".")
        
        while !parts.isEmpty {
            if let entity = entities[parts.joined(separator: ".")] { return entity }
            parts = Array(parts.dropFirst())
        }
        
        return nil
    }
    
    private static func process(_ data: Data) throws -> [String: String] {
        if let decoded = decode(data) {
            var entities = [String: String]()
            
            decoded.forEach {
                let entityName = $0.key
                $0.value.properties.forEach {
                    entities[$0] = entityName
                }
                $0.value.resources.forEach {
                    entities[$0] = entityName
                }
            }
            
            return entities
        }
        return [:]
    }
    
    private static func decode(_ data: Data) -> [String: Entity]? {
        do {
            return try JSONDecoder().decode([String: Entity].self, from: data)
        } catch {
            Logger.log(items: error)
        }
        return nil
    }
    
}
