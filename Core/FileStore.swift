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
import Configuration

public class FileStore {

    private let groupIdentifier: String = ContentBlockerStoreConstants.groupName

    public init() { }

    public func persist(_ data: Data, for configuration: Configuration) throws {
        do {
            try data.write(to: persistenceLocation(for: configuration), options: .atomic)
        } catch {
            Pixel.fire(pixel: .fileStoreWriteFailed, error: error, withAdditionalParameters: ["config": configuration.rawValue])
            throw error
        }
    }

    func removeData(forFile file: String) -> Bool {
        var fileUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        fileUrl = fileUrl!.appendingPathComponent(file)
        guard let fileUrl = fileUrl else { return false }
        guard FileManager.default.fileExists(atPath: fileUrl.path) else { return true }

        do {
            try FileManager.default.removeItem(at: fileUrl)
        } catch {
            return false
        }

        return true
    }

    public func loadAsString(for configuration: Configuration) -> String? {
        try? String(contentsOf: persistenceLocation(for: configuration))
    }

    public func loadAsData(for configuration: Configuration) -> Data? {
        do {
            return try Data(contentsOf: persistenceLocation(for: configuration))
        } catch {
            let nserror = error as NSError
            if nserror.domain != NSCocoaErrorDomain || nserror.code != NSFileReadNoSuchFileError {
                Pixel.fire(pixel: .trackerDataCouldNotBeLoaded, error: error)
            }
            return nil
        }
    }

    func hasData(for configuration: Configuration) -> Bool {
        FileManager.default.fileExists(atPath: persistenceLocation(for: configuration).path)
    }

    func persistenceLocation(for configuration: Configuration) -> URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        return path!.appendingPathComponent(configuration.storeKey)
    }

}
