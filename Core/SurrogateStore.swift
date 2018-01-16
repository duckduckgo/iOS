//
//  SurrogateStore.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

class SurrogateStore {

    var js: String? {
        get {
            return try? String(contentsOf: persistenceLocation(), encoding: .utf8)
        }
    }
    
    func persist(data: Data) {
        guard let surrogateFile = String(data: data, encoding: .utf8) else { return }
        
        var lines = surrogateFile.components(separatedBy: .newlines)
        lines = lines.filter({ !$0.hasPrefix("#") })
        lines = lines.filter({ !$0.hasSuffix("application/javascript") })

        let js = lines.joined(separator: "\n")
        
        try? js.write(to: persistenceLocation(), atomically: true, encoding: .utf8)
    }
    
    private func persistenceLocation() -> URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ContentBlockerStoreConstants.groupName)
        return path!.appendingPathComponent("surrogate.js")
    }

}
