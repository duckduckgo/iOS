//
//  MaliciousSiteProtectionManager.swift
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

import BrowserServicesKit
import Combine
import Common
import Foundation
import MaliciousSiteProtection
import Networking
import PixelKit

public class MaliciousSiteProtectionManager: MaliciousSiteDetecting {
    private let detector: MaliciousSiteDetecting
    private let updateManager: MaliciousSiteProtection.UpdateManager
    //private let detectionPreferences: MaliciousSiteProtectionPreferences
    //private let featureFlagger: FeatureFlagger
    //private let configManager: PrivacyConfigurationManaging

    //private var featureFlagsCancellable: AnyCancellable?
   // private var detectionPreferencesEnabledCancellable: AnyCancellable?
    private(set) var updateTask: Task<Void, Error>?

    init(
        apiEnvironment: MaliciousSiteDetector.APIEnvironment = .production,
        apiService: APIService = DefaultAPIService(urlSession: .shared),
        embeddedDataProvider: MaliciousSiteProtection.EmbeddedDataProviding? = nil,
        dataManager: MaliciousSiteProtection.DataManager? = nil,
        detector: MaliciousSiteProtection.MaliciousSiteDetecting? = nil,
        //detectionPreferences: MaliciousSiteProtectionPreferences = MaliciousSiteProtectionPreferences.shared,
        //featureFlagger: FeatureFlagger? = nil,
        //configManager: PrivacyConfigurationManaging? = nil
        updateIntervalProvider: UpdateManager.UpdateIntervalProvider? = nil
    ) {
        //self.featureFlagger = featureFlagger ?? NSApp.delegateTyped.featureFlagger
        //self.configManager = configManager ?? AppPrivacyFeatures.shared.contentBlocking.privacyConfigurationManager

        let embeddedDataProvider = embeddedDataProvider ?? EmbeddedDataProvider()
        let dataManager = dataManager ?? {
            let configurationUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileStore = MaliciousSiteProtection.FileStore(dataStoreURL: configurationUrl)
            return MaliciousSiteProtection.DataManager(fileStore: fileStore, embeddedDataProvider: embeddedDataProvider, fileNameProvider: Self.fileName(for:))
        }()

        self.detector = detector ?? MaliciousSiteDetector(apiEnvironment: apiEnvironment, service: apiService, dataManager: dataManager, eventMapping: Self.debugEvents)
        self.updateManager = MaliciousSiteProtection.UpdateManager(apiEnvironment: apiEnvironment, service: apiService, dataManager: dataManager, updateIntervalProvider: updateIntervalProvider ?? Self.updateInterval)
        //self.detectionPreferences = detectionPreferences

        setupBindings()
    }

    private static let debugEvents = EventMapping<MaliciousSiteProtection.Event> {event, _, _, _ in
        PixelKit.fire(event)
    }

    private func setupBindings() {
//        if featureFlagger.isFeatureOn(.maliciousSiteProtectionErrorPage) {
//            subscribeToDetectionPreferences()
//            return
//        }
//
//        guard let overridesHandler = featureFlagger.localOverrides?.actionHandler as? FeatureFlagOverridesPublishingHandler<FeatureFlag> else { return }
//        featureFlagsCancellable = overridesHandler.flagDidChangePublisher
//            .filter { $0.0 == .maliciousSiteProtectionErrorPage }
//            .sink { [weak self] change in
//                guard let self else { return }
//                if change.1 {
//                    subscribeToDetectionPreferences()
//                } else {
//                    detectionPreferencesEnabledCancellable = nil
//                    stopUpdateTasks()
//                }
//            }
    }

    private func subscribeToDetectionPreferences() {
//        detectionPreferencesEnabledCancellable = detectionPreferences.$isEnabled
//            .sink { [weak self] isEnabled in
//                self?.handleIsEnabledChange(enabled: isEnabled)
//            }
    }

    private func handleIsEnabledChange(enabled: Bool) {
        if enabled {
            startUpdateTasks()
        } else {
            stopUpdateTasks()
        }
    }

    private func startUpdateTasks() {
        self.updateTask = updateManager.startPeriodicUpdates()
    }

    private func stopUpdateTasks() {
        updateTask?.cancel()
        updateTask = nil
    }

    // MARK: - Public

    public func evaluate(_ url: URL) async -> ThreatKind? {
//        guard configManager.privacyConfig.isFeature(.maliciousSiteProtection, enabledForDomain: url.host) || featureFlagger.localOverrides?.override(for: FeatureFlag.maliciousSiteProtectionErrorPage) == true,
//              detectionPreferences.isEnabled || !(featureFlagger.isFeatureOn(.maliciousSiteProtectionPreferences) || featureFlagger.localOverrides?.override(for: FeatureFlag.maliciousSiteProtectionPreferences) == true) else { return .none }

        return await detector.evaluate(url)
    }
}
