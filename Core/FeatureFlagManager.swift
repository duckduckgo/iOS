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

struct FeatureFlagConfig: Decodable {

    let version: Int
    let rollouts: [FeatureFlag]
    
    func features(mergingPreviousFeatures previousFeatures: [String: Feature]?) -> [String: Feature] {
        rollouts.reduce(into: [String: Feature]()) { dict, featureFlag in
            // It's important we use previousFeatures to preserve their allocated percentiles, to avoid redistributing users
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

struct Feature {
    
    let name: String
    let rolloutPercentage: Int
    
    private let clientPercentile: Int
    
    var isEnabled: Bool {
        return clientPercentile <= rolloutPercentage
    }

    init(featureFlag: FeatureFlag) {
        
        self.name = featureFlag.featureName
        self.rolloutPercentage = featureFlag.rolloutToPercentage
        
        // By generating from 1 to a 100 and using `clientPercentile <= rolloutPercentage`, we ensure 0% rollout means 0, and 100% means 100%
        // It's critical this is stored and not generated again for the same feature when there's a config change, so the users that see a feature don't get completely reallocated
        self.clientPercentile = Int.random(in: 1...100)
    }
}

class FeatureFlagManager {
    
    // TODO maybe should be async with notification for did change and just embrace it?
    
    // TODO how are we gonna make this mockable for testing?
        
    // TODO should be in appURLs?
    private static let stagingURL = URL(string: "https://staticcdn.duckduckgo.com/remotefeatureflagging/config/staging/ios-config.json")!
    private static let productionURL = URL(string: "https://staticcdn.duckduckgo.com/remotefeatureflagging/config/v1/ios-config.json")!
    
    private let storage: FeatureFlagUserDefaults
    
    private static var endpointURL: URL {
        return isDebugBuild ? stagingURL : productionURL
    }
    
    init(storage: FeatureFlagUserDefaults = FeatureFlagUserDefaults()) {
        self.storage = storage
    }
    
    func getJSONFile() {
        
        let request = URLRequest(url: FeatureFlagManager.endpointURL)
      
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) -> Void in
            guard let weakSelf = self else {
                fatalError("TODO don't ship with this fatal error, do some actual error handling")
            }
            do {
                let config = try weakSelf.processResult(data: data, error: error)
                guard config.version > weakSelf.storage.lastConfigVersion else { return }
                
                let previousFeatures = weakSelf.storage.features
                let newFeatures = config.features(mergingPreviousFeatures: previousFeatures)
                weakSelf.storage.features = newFeatures
                weakSelf.storage.featureFlagConfig = config
            } catch {
                fatalError("TODO don't ship with this fatal error, do some actual error handling")
            }
        }
        task.resume()
    }

    private func processResult(data: Data?, error: Error?) throws -> FeatureFlagConfig {
        if let error = error { throw error }
        guard let data = data else { throw ApiRequestError.noData }
        let config = try JSONDecoder().decode(FeatureFlagConfig.self, from: data)

        return config
    }
    
}

class FeatureFlagUserDefaults {
    
    private struct Keys {
        static let configKey = "com.duckduckgo.featureFlags.configKey"
        static let featuresKey = "com.duckduckgo.featureFlags.featuresKey"
    }

    
    private var userDefaults: UserDefaults {
        return UserDefaults.standard
    }

    // Currently save the whole config cos why not, but we could just save the version
    public var featureFlagConfig: FeatureFlagConfig? {
        get {
            if let data = userDefaults.data(forKey: Keys.configKey) {
                return (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? FeatureFlagConfig)
            }
            return nil
        }
        set(newConfig) {
            guard let newConfig = newConfig else {
                return
            }
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newConfig, requiringSecureCoding: false) else { return }
            userDefaults.set(data, forKey: Keys.configKey)
        }
    }
    
    public var lastConfigVersion: Int {
        return featureFlagConfig?.version ?? -1
    }
    
    public var features: [String: Feature] {
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
