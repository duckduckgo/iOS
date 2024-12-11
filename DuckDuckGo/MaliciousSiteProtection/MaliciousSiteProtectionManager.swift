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

final class MaliciousSiteProtectionManager: MaliciousSiteDetecting {
    private let detector: MaliciousSiteDetecting
    private let updateManager: MaliciousSiteProtection.UpdateManager
    //private let detectionPreferences: MaliciousSiteProtectionPreferences
    private let featureFlagger: FeatureFlagger
    //private let configManager: PrivacyConfigurationManaging

    private var featureFlagsCancellable: AnyCancellable?
   // private var detectionPreferencesEnabledCancellable: AnyCancellable?
    private(set) var updateTask: Task<Void, Error>?

    init(
        detector: MaliciousSiteDetecting,
        updateManager: MaliciousSiteProtection.UpdateManager,
        featureFlagger: FeatureFlagger
    ) {
        self.detector = detector
        self.updateManager = updateManager
        self.featureFlagger = featureFlagger
        //self.configManager = configManager ?? AppPrivacyFeatures.shared.contentBlocking.privacyConfigurationManager
        setupBindings()
    }

    convenience init(apiEnvironment: MaliciousSiteDetector.APIEnvironment = .production) {
        let embeddedDataProvider = EmbeddedDataProvider()
        let configurationUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileStore = MaliciousSiteProtection.FileStore(dataStoreURL: configurationUrl)
        let dataManager = MaliciousSiteProtection.DataManager(
            fileStore: fileStore,
            embeddedDataProvider: embeddedDataProvider,
            fileNameProvider: Self.fileName(for:)
        )
        let apiService = DefaultAPIService(urlSession: .shared)
        let detector = MaliciousSiteDetector(
            apiEnvironment: apiEnvironment,
            service: apiService,
            dataManager: dataManager,
            eventMapping: Self.debugEvents
        )
        let updateManager = MaliciousSiteProtection.UpdateManager(
            apiEnvironment: apiEnvironment,
            service: apiService,
            dataManager: dataManager,
            updateIntervalProvider: Self.updateInterval
        )
        let featureFlagger = AppDependencyProvider.shared.featureFlagger

        self.init(detector: detector, updateManager: updateManager, featureFlagger: featureFlagger)
    }

    private static let debugEvents = EventMapping<MaliciousSiteProtection.Event> {event, _, _, _ in
        PixelKit.fire(event)
    }

}

// MARK: - Public

extension MaliciousSiteProtectionManager {

    func evaluate(_ url: URL) async -> ThreatKind? {
//        guard configManager.privacyConfig.isFeature(.maliciousSiteProtection, enabledForDomain: url.host),
//              detectionPreferences.isEnabled else { return .none }

        return await detector.evaluate(url)
    }

}

// MARK: - Private

private extension MaliciousSiteProtectionManager {

    func setupBindings() {
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

    func subscribeToDetectionPreferences() {
//        detectionPreferencesEnabledCancellable = detectionPreferences.$isEnabled
//            .sink { [weak self] isEnabled in
//                self?.handleIsEnabledChange(enabled: isEnabled)
//            }
    }

    func handleIsEnabledChange(enabled: Bool) {
        if enabled {
            startUpdateTasks()
        } else {
            stopUpdateTasks()
        }
    }

    func startUpdateTasks() {
        updateTask = updateManager.startPeriodicUpdates()
    }

    func stopUpdateTasks() {
        updateTask?.cancel()
        updateTask = nil
    }

}
