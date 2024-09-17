//
//  ConfigurationStore.swift
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

import Foundation
import os.log
import Core
import Configuration
import Persistence

struct ConfigurationStore: ConfigurationStoring {

    enum Error: Swift.Error {
        case unsupportedConfig
    }

    private var defaults: KeyValueStoring

    private var privacyConfigurationEtagKey: String {
        return "privacyConfiguration"
    }
    private var privacyConfigurationEtag: String? {
        get {
            defaults.object(forKey: privacyConfigurationEtagKey) as? String
        }
        set {
            defaults.set(newValue, forKey: privacyConfigurationEtagKey)
        }
    }

    init(defaults: KeyValueStoring = UserDefaults.configurationGroupDefaults) {
        self.defaults = defaults
    }

    func log() {
        Logger.config.log("privacyConfigurationEtag \(self.privacyConfigurationEtag ?? "", privacy: .public)")
    }

    func loadData(for configuration: Configuration) -> Data? {
        let file = fileUrl(for: configuration)
        var data: Data?
        var coordinatorError: NSError?

        NSFileCoordinator().coordinate(readingItemAt: file, error: &coordinatorError) { fileUrl in
            do {
                data = try Data(contentsOf: fileUrl)
            } catch {
                let nserror = error as NSError

                if nserror.domain != NSCocoaErrorDomain || nserror.code != NSFileReadNoSuchFileError {
                    Pixel.fire(pixel: .trackerDataCouldNotBeLoaded, error: error, withAdditionalParameters: ["target": "vpn"])
                }
            }
        }

        if let coordinatorError {
            Logger.config.error("Unable to read \(configuration.rawValue, privacy: .public): \(coordinatorError.localizedDescription, privacy: .public)")
        }

        return data
    }
    
    func loadEtag(for configuration: Configuration) -> String? {
        if configuration == .privacyConfiguration {
            return privacyConfigurationEtag
        }

        return nil
    }
    
    func loadEmbeddedEtag(for configuration: Configuration) -> String? {
        // If we ever need the full embedded config, we need to return its etag here
        return nil
    }
    
    mutating func saveData(_ data: Data, for configuration: Configuration) throws {
        guard configuration == .privacyConfiguration else { throw Error.unsupportedConfig }
        let file = fileUrl(for: configuration)
        var coordinatorError: NSError?

        NSFileCoordinator().coordinate(writingItemAt: file, options: .forReplacing, error: &coordinatorError) { fileUrl in
            do {
                try data.write(to: fileUrl, options: .atomic)
            } catch {
                Logger.config.error("Unable to write \(configuration.rawValue, privacy: .public): \(error.localizedDescription, privacy: .public)")
            }
        }

        if let coordinatorError {
            Logger.config.error("Unable to write \(configuration.rawValue, privacy: .public): \(coordinatorError.localizedDescription, privacy: .public)")
        }
    }
    
    mutating func saveEtag(_ etag: String, for configuration: Configuration) throws {
        guard configuration == .privacyConfiguration else { throw Error.unsupportedConfig }

        privacyConfigurationEtag = etag
    }
    
    func fileUrl(for configuration: Configuration) -> URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "\(Global.groupIdPrefix).app-configuration")
        return path!.appendingPathComponent(configuration.storeKey)
    }
}
