//
//  MaliciousSiteProtectionManager.swift
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
    private let maliciousSiteProtectionFeatureFlagger: MaliciousSiteProtectionFeatureFlagger
    private let preferencesManager: MaliciousSiteProtectionPreferencesPublishing

    private var preferencesManagerCancellable: AnyCancellable?
    private var updateTask: Task<Void, Error>?

    var isBackgroundUpdatesEnabled: Bool { updateTask != nil }

    private static let debugEvents = EventMapping<MaliciousSiteProtection.Event> { event, _, _, _ in
        PixelKit.fire(event)
    }

    init(
        apiEnvironment: MaliciousSiteDetector.APIEnvironment = .production,
        apiService: APIService = DefaultAPIService(urlSession: .shared),
        embeddedDataProvider: MaliciousSiteProtection.EmbeddedDataProviding = EmbeddedDataProvider(),
        dataManager: MaliciousSiteProtection.DataManager? = nil,
        detector: MaliciousSiteProtection.MaliciousSiteDetecting? = nil,
        preferencesManager: MaliciousSiteProtectionPreferencesPublishing = MaliciousSiteProtectionPreferencesManager(),
        maliciousSiteProtectionFeatureFlagger: MaliciousSiteProtectionFeatureFlagger = MaliciousSiteProtectionFeatureFlags(),
        updateIntervalProvider: UpdateManager.UpdateIntervalProvider? = nil
    ) {
        let embeddedDataProvider = EmbeddedDataProvider()

        let dataManager = dataManager ?? MaliciousSiteProtection.DataManager(
            fileStore: MaliciousSiteProtection.FileStore(
                dataStoreURL: FileManager.default.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                )
                .first!
            ),
            embeddedDataProvider: embeddedDataProvider,
            fileNameProvider: Self.fileName(for:)
        )

        self.detector = detector ?? MaliciousSiteDetector(
            apiEnvironment: apiEnvironment,
            service: apiService,
            dataManager: dataManager,
            eventMapping: Self.debugEvents
        )

        self.updateManager = MaliciousSiteProtection.UpdateManager(
            apiEnvironment: apiEnvironment,
            service: apiService,
            dataManager: dataManager,
            updateIntervalProvider: updateIntervalProvider ?? Self.updateInterval
        )

        self.preferencesManager = preferencesManager
        self.maliciousSiteProtectionFeatureFlagger = maliciousSiteProtectionFeatureFlagger

        self.setupBindings()
    }

}

// MARK: - Public

extension MaliciousSiteProtectionManager {

    func evaluate(_ url: URL) async -> ThreatKind? {
        guard
            maliciousSiteProtectionFeatureFlagger.shouldDetectMaliciousThreat(forDomain: url.host),
            preferencesManager.isEnabled
        else {
            return .none
        }

        return await detector.evaluate(url)
    }

}

// MARK: - Private

private extension MaliciousSiteProtectionManager {

    func setupBindings() {
        guard maliciousSiteProtectionFeatureFlagger.isMaliciousSiteProtectionEnabled else { return }
        subscribeToDetectionPreferences()
    }

    func subscribeToDetectionPreferences() {
        preferencesManagerCancellable = preferencesManager
            .isEnabledPublisher
            .sink { [weak self] isEnabled in
                self?.handleIsEnabledChange(enabled: isEnabled)
            }
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

protocol MaliciousSiteProtectionPreferencesPublishing {
    var isEnabled: Bool { get }
    var isEnabledPublisher: AnyPublisher<Bool, Never> { get }
}

protocol MaliciousSiteProtectionPreferencesManaging {
    var isEnabled: Bool { get set }
}

final class MaliciousSiteProtectionPreferencesManager: MaliciousSiteProtectionPreferencesManaging, MaliciousSiteProtectionPreferencesPublishing {
    @Published var isEnabled: Bool

    var isEnabledPublisher: AnyPublisher<Bool, Never> { $isEnabled.eraseToAnyPublisher() }

    init() {
        isEnabled = true
    }
}
