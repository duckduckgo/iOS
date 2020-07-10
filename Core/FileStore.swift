//
//  FileStore.swift
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

public class FileStore {
    
    private let groupIdentifier: String = ContentBlockerStoreConstants.groupName

    public init() { }
    
    func persist(_ data: Data?, forConfiguration config: ContentBlockerRequest.Configuration) -> Bool {
        guard let data = data else { return false }
        do {
            try data.write(to: persistenceLocation(forConfiguration: config))
            return true
        } catch {
            Pixel.fire(pixel: .fileStoreWriteFailed, error: error, withAdditionalParameters: ["config": config.rawValue ])
            return false
        }
    }
    
    func loadAsString(forConfiguration config: ContentBlockerRequest.Configuration) -> String? {
        return try? String(contentsOf: persistenceLocation(forConfiguration: config))
    }
    
    func loadAsData(forConfiguration config: ContentBlockerRequest.Configuration) -> Data? {
        do {
            return try Data(contentsOf: persistenceLocation(forConfiguration: config))
        } catch {
            let nserror = error as NSError
            if nserror.domain != NSCocoaErrorDomain || nserror.code != NSFileReadNoSuchFileError {
                Pixel.fire(pixel: .trackerDataCouldNotBeLoaded, error: error)
            }
            return nil
        }
    }
    
    func hasData(forConfiguration config: ContentBlockerRequest.Configuration) -> Bool {
        return FileManager.default.fileExists(atPath: persistenceLocation(forConfiguration: config).path)
    }

    func persistenceLocation(forConfiguration config: ContentBlockerRequest.Configuration) -> URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        return path!.appendingPathComponent(config.rawValue)
    }

}
