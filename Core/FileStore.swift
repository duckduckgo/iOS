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
import PixelExperimentKit

public class FileStore {

    private let groupIdentifier: String = ContentBlockerStoreConstants.configurationGroupName

    public init() { }

    public func persist(_ data: Data, for configuration: Configuration) throws {
        let file = persistenceLocation(for: configuration)
        var coordinatorError: NSError?
        var writeError: Error?

        NSFileCoordinator().coordinate(writingItemAt: file, options: .forReplacing, error: &coordinatorError) { fileUrl in
            do {
                try data.write(to: fileUrl, options: .atomic)
            } catch {
                Pixel.fire(pixel: .fileStoreWriteFailed, error: error, withAdditionalParameters: ["config": configuration.rawValue])
                writeError = error
            }
        }

        if let writeError {
            throw writeError
        }
        if let coordinatorError {
            Pixel.fire(pixel: .fileStoreCoordinatorFailed, error: coordinatorError, withAdditionalParameters: ["config": configuration.rawValue])
            throw coordinatorError
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
        let file = persistenceLocation(for: configuration)
        var data: Data?
        var coordinatorError: NSError?

        NSFileCoordinator().coordinate(readingItemAt: file, error: &coordinatorError) { fileUrl in
            do {
                data = try Data(contentsOf: fileUrl)
            } catch {
                let nserror = error as NSError
                if nserror.domain != NSCocoaErrorDomain || nserror.code != NSFileReadNoSuchFileError {
                    if configuration == .trackerDataSet, let experimentName = TDSOverrideExperimentMetrics.activeTDSExperimentNameWithCohort {
                        let parameters = [
                            "experimentName": experimentName,
                            "etag": UserDefaultsETagStorage().loadEtag(for: .trackerDataSet) ?? ""
                        ]
                        Pixel.fire(pixel: .trackerDataCouldNotBeLoaded, error: error, withAdditionalParameters: parameters)
                    } else {
                        Pixel.fire(pixel: .trackerDataCouldNotBeLoaded, error: error)
                    }
                }
            }
        }

        if let coordinatorError {
            Pixel.fire(pixel: .fileStoreCoordinatorFailed, error: coordinatorError, withAdditionalParameters: ["config": configuration.rawValue])
        }

        return data
    }

    func hasData(for configuration: Configuration) -> Bool {
        FileManager.default.fileExists(atPath: persistenceLocation(for: configuration).path)
    }

    public func persistenceLocation(for configuration: Configuration) -> URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        return path!.appendingPathComponent(configuration.storeKey)
    }

}
