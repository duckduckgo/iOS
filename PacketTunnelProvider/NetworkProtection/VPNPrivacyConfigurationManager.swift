//
//  VPNPrivacyConfigurationManager.swift
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
import Core
import BrowserServicesKit
import Combine
import Common

public final class VPNPrivacyConfigurationManager: PrivacyConfigurationManaging {

    static let shared = VPNPrivacyConfigurationManager()

    private let lock = NSLock()

    var embeddedConfigData: Data {
        let configString = """
    {
            "readme": "https://github.com/duckduckgo/privacy-configuration",
            "version": 1693838894358,
            "features": {
                "networkProtection": {
                    "state": "enabled",
                    "exceptions": [],
                    "settings": {}
                }
            },
            "unprotectedTemporary": []
        }
    """
        let data = configString.data(using: .utf8)
        return data!
    }

    private var _fetchedConfigData: PrivacyConfigurationManager.ConfigurationData?
    private(set) public var fetchedConfigData: PrivacyConfigurationManager.ConfigurationData? {
        get {
            lock.lock()
            let data = _fetchedConfigData
            lock.unlock()
            return data
        }
        set {
            lock.lock()
            _fetchedConfigData = newValue
            lock.unlock()
        }
    }

    public var currentConfig: Data {
        if let fetchedData = fetchedConfigData {
            return fetchedData.rawData
        }
        return embeddedConfigData
    }

    private let updatesSubject = PassthroughSubject<Void, Never>()
    public var updatesPublisher: AnyPublisher<Void, Never> {
        updatesSubject.eraseToAnyPublisher()
    }

    public var privacyConfig: BrowserServicesKit.PrivacyConfiguration {
        guard let privacyConfigurationData = try? PrivacyConfigurationData(data: currentConfig) else {
            fatalError("Could not retrieve privacy configuration data")
        }
        let privacyConfig = privacyConfiguration(withData: privacyConfigurationData,
                                                 internalUserDecider: internalUserDecider)
        return privacyConfig
    }

    public var internalUserDecider: InternalUserDecider = DefaultInternalUserDecider(store: InternalUserDeciderStoreMock())

    @discardableResult
    public func reload(etag: String?, data: Data?) -> PrivacyConfigurationManager.ReloadResult {
        let result: PrivacyConfigurationManager.ReloadResult

        if let etag = etag, let data = data {
            result = .downloaded

            do {
                let configData = try PrivacyConfigurationData(data: data)
                fetchedConfigData = (data, configData, etag)
                updatesSubject.send(())
            } catch {
                Pixel.fire(pixel: .trackerDataParseFailed, error: error, withAdditionalParameters: ["target": "vpn"])
                fetchedConfigData = nil
                return .embeddedFallback
            }
        } else {
            fetchedConfigData = nil
            result = .embedded
        }

        return result
    }
}

func privacyConfiguration(withData data: PrivacyConfigurationData,
                          internalUserDecider: InternalUserDecider) -> PrivacyConfiguration {
    let domain = MockDomainsProtectionStore()
    return AppPrivacyConfiguration(data: data,
                                   identifier: UUID().uuidString,
                                   localProtection: domain,
                                   internalUserDecider: internalUserDecider)
}

final class MockDomainsProtectionStore: DomainsProtectionStore {
    var unprotectedDomains = Set<String>()

    func disableProtection(forDomain domain: String) {
        unprotectedDomains.insert(domain)
    }

    func enableProtection(forDomain domain: String) {
        unprotectedDomains.remove(domain)
    }
}

final class InternalUserDeciderStoreMock: InternalUserStoring {
    var isInternalUser: Bool = false
}
