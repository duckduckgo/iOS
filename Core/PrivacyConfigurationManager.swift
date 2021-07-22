//
//  PrivacyConfigurationManager.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

public class PrivacyConfigurationManager {
    public struct Constants {
        public static let embeddedConfigETag = "\"d2a60035e07218b91f951ac872c503e1\""
    }
    
    public enum ReloadResult {
        case embedded
        case embeddedFallback
        case downloaded
    }
    
    public typealias Configuration = (config: PrivacyConfiguration, etag: String)
    
    private let lock = NSLock()
    
    private var _fetchedData: Configuration?
    private(set) public var fetchedData: Configuration? {
        get {
            lock.lock()
            let data = _fetchedData
            lock.unlock()
            return data
        }
        set {
            lock.lock()
            _fetchedData = newValue
            lock.unlock()
        }
    }
    
    private var _embeddedData: Configuration!
    private(set) public var embeddedData: Configuration {
        get {
            lock.lock()
            let data: Configuration
            // List is loaded lazily when needed
            if let embedded = _embeddedData {
                data = embedded
            } else {
                let configData = try? JSONDecoder().decode(PrivacyConfiguration.self, from: Self.loadEmbeddedAsData())
                _embeddedData = (configData!, Constants.embeddedConfigETag)
                data = _embeddedData
            }
            lock.unlock()
            return data
        }
        set {
            lock.lock()
            _embeddedData = newValue
            lock.unlock()
        }
    }
    
    public static let shared = PrivacyConfigurationManager()
    
    public var privacyConfig: PrivacyConfiguration {
        if let data = fetchedData {
            return data.config
        }
        return embeddedData.config
    }

    init(configData: PrivacyConfiguration) {
        _fetchedData = (configData, "")
    }

    init() {
        reload(etag: UserDefaultsETagStorage().etag(for: .privacyConfiguration))
    }
    
    @discardableResult
    public func reload(etag: String?) -> ReloadResult {
        
        let result: ReloadResult
        
        if let etag = etag, let data = FileStore().loadAsData(forConfiguration: .privacyConfiguration) {
            result = .downloaded
            
            do {
                // This might fail if the downloaded data is corrupt or format has changed unexpectedly
                let data = try JSONDecoder().decode(PrivacyConfiguration.self, from: data)
                fetchedData = (data, etag)
            } catch {
                Pixel.fire(pixel: .privacyConfigurationParseFailed, error: error)
                fetchedData = nil
                return .embeddedFallback
            }
        } else {
            fetchedData = nil
            result = .embedded
        }
        
        return result
    }
    
    static var embeddedUrl: URL {
        return Bundle.core.url(forResource: "ios-config", withExtension: "json")!
    }

    static func loadEmbeddedAsData() -> Data {
        let json = try? Data(contentsOf: embeddedUrl)
        return json!
    }
}
