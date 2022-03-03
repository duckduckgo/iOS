//
//  FeatureFlagManager.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

enum SupportedFeature: String {
    case someNewFeature = "some_new_feature"
    case featureOff = "feature_off"
    case featureOn = "feature_on"
}

/*
 At present, the config is only fetched on app start (in the app delegate). However, this is async, so anything using feature flagging should be aware that wether or not the fature flag is enabled could change at any time.
 */
class FeatureFlagManager {
        
    // TODO I should probably also test mergingPreviousFeatures
        
    public struct Notifications {
        public static let featureFlagConfigDidChange = Notification.Name("com.duckduckgo.app.featureFlagConfigDidChange")
    }
    
    // TODO should be in appURLs?
    private static let stagingURL = URL(string: "https://staticcdn.duckduckgo.com/remotefeatureflagging/config/staging/ios-config.json")!
    private static let productionURL = URL(string: "https://staticcdn.duckduckgo.com/remotefeatureflagging/config/v1/ios-config.json")!
    
    private let storage: FeatureFlagUserDefaults
    
    private static var endpointURL: URL {
        return isDebugBuild ? stagingURL : productionURL
    }
    
    // Values for feature flags for testing can be provided by providing alternative storage
    init(storage: FeatureFlagUserDefaults = FeatureFlagUserDefaults()) {
        self.storage = storage
    }
    
    func isFeatureEnabled(_ feature: SupportedFeature) -> Bool {
        guard let savedFeature = storage.savedFeatures()[feature.rawValue] else {
            return false
        }
        return savedFeature.isEnabled
    }
    
    func getLatestConfigAndProcess() {
        
        let request = URLRequest(url: FeatureFlagManager.endpointURL)
      
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) -> Void in
            guard let weakSelf = self else {
                assertionFailure("self nil in FeatureFlagManager")
                return
            }
            do {
                let config = try weakSelf.parseConfigData(data, error: error)
                let configChanged = weakSelf.storage.saveConfigIfNeeded(config)
                if configChanged {
                    NotificationCenter.default.post(name: Notifications.featureFlagConfigDidChange, object: self)
                }
            } catch {
                assertionFailure("Error processing feature flag config")
            }
        }
        task.resume()
    }

    private func parseConfigData(_ data: Data?, error: Error?) throws -> FeatureFlagConfig {
        if let error = error { throw error }
        guard let data = data else { throw ApiRequestError.noData }
        let config = try JSONDecoder().decode(FeatureFlagConfig.self, from: data)

        return config
    }
    
}

protocol FeatureFlagStorage {
    func saveConfigIfNeeded(_ config: FeatureFlagConfig) -> Bool
    func savedFeatures() -> [String: Feature]
}

class FeatureFlagUserDefaults: FeatureFlagStorage {
    
    private struct Keys {
        static let lastConfigVersionKey = "com.duckduckgo.featureFlags.lastConfigVersionKey"
        static let featuresKey = "com.duckduckgo.featureFlags.featuresKey"
    }

    private var userDefaults: UserDefaults {
        return UserDefaults.standard
    }

    @discardableResult
    func saveConfigIfNeeded(_ config: FeatureFlagConfig) -> Bool {
        guard config.version > lastConfigVersion else { return false }
        
        features = config.features(mergingPreviousFeatures: features)
        lastConfigVersion = config.version
        return true
    }
    
    func savedFeatures() -> [String: Feature] {
        return features
    }
    
    private var lastConfigVersion: Int {
        get {
            userDefaults.integer(forKey: Keys.lastConfigVersionKey)
        }
        set(latestConfigVersion) {
            userDefaults.set(latestConfigVersion, forKey: Keys.lastConfigVersionKey)
        }
    }
    
    private var features: [String: Feature] {
        get {
            if let data = userDefaults.data(forKey: Keys.featuresKey) {
                return (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: Feature]) ?? [:]
            }
            return [:]
        }
        set(newFeatures) {
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newFeatures, requiringSecureCoding: false) else { return }
            userDefaults.set(data, forKey: Keys.featuresKey)
        }
    }
}

class Feature: NSObject, NSCoding {
    
    let name: String
    let rolloutPercentage: Int
    var isEnabled: Bool {
        return clientPercentile <= rolloutPercentage
    }
    
    private let clientPercentile: Int
    
    override init() {
        fatalError("Feature must not be created without a clientPercentile, use init(featureFlag: FeatureFlag)")
    }

    fileprivate init(featureFlag: FeatureFlag) {
        
        self.name = featureFlag.featureName
        self.rolloutPercentage = featureFlag.rolloutToPercentage
        
        // By generating from 1 to a 100 and using `clientPercentile <= rolloutPercentage`, we ensure 0% rollout means 0, and 100% means 100%
        // It's critical this is stored and not generated again for the same feature when there's a config change, so the users that see a feature don't get completely reallocated
        self.clientPercentile = Int.random(in: 1...100)
    }
    
    // NSCoding
    private struct NSCodingKeys {
        static let name = "name"
        static let rolloutPercentage = "rolloutPercentage"
        static let clientPercentile = "clientPercentile"
    }
    
    required init?(coder: NSCoder) {
        let name = coder.decodeObject(forKey: NSCodingKeys.name) as? String
        guard let name = name else {
            return nil
        }
        self.name = name
        self.rolloutPercentage = coder.decodeInteger(forKey: NSCodingKeys.rolloutPercentage)
        self.clientPercentile = coder.decodeInteger(forKey: NSCodingKeys.clientPercentile)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: NSCodingKeys.name)
        coder.encode(rolloutPercentage, forKey: NSCodingKeys.rolloutPercentage)
        coder.encode(clientPercentile, forKey: NSCodingKeys.clientPercentile)
    }
}

struct FeatureFlagConfig: Decodable {

    let version: Int
    let rollouts: [FeatureFlag]
    
    func features(mergingPreviousFeatures previousFeatures: [String: Feature]?) -> [String: Feature] {
        rollouts.reduce(into: [String: Feature]()) { dict, featureFlag in
            // It's important we use previousFeatures to preserve their allocated percentiles, to avoid redistributing users
            // However, if a feature is no longer present in the config, we don't currently keep it stored, so if the feature is ever readded, users will be reallocated.
            if let previousFeature = previousFeatures?[featureFlag.featureName] {
                dict[previousFeature.name] = previousFeature
            } else {
                let feature = Feature(featureFlag: featureFlag)
                dict[feature.name] = feature
            }
        }
    }
}

struct FeatureFlag: Decodable {
    
    let featureName: String
    let rolloutToPercentage: Int
    
}
