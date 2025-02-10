//
//  MaliciousSiteProtectionDatasetsFetcher.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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
import MaliciousSiteProtection
import BackgroundTasks
import Core
import Combine

protocol MaliciousSiteProtectionDatasetsFetching {
    func startFetching()
    func registerBackgroundRefreshTaskHandler()
}

final class MaliciousSiteProtectionDatasetsFetcher: MaliciousSiteProtectionDatasetsFetching {
    private let featureFlagger: MaliciousSiteProtectionFeatureFlagger & MaliciousSiteProtectionFeatureFlagsSettingsProvider
    private let userPreferencesManager: MaliciousSiteProtectionPreferencesProvider
    private let dateProvider: () -> Date
    private let updateManager: MaliciousSiteUpdateManaging
    private let backgroundTaskScheduler: BGTaskScheduling
    private let application: BackgroundRefreshCapable

    private var preferencesManagerCancellable: AnyCancellable?

    private var shouldUpdateHashPrefixSets: Bool {
        // Absolute interval to avoid never updating the dataset if the `lastHashPrefixSetUpdateDate` is mistakenly set in the far future
        abs(dateProvider().timeIntervalSince(updateManager.lastHashPrefixSetUpdateDate)) > .minutes(featureFlagger.hashPrefixUpdateFrequency)
    }

    private var shouldUpdateFilterSets: Bool {
        // Absolute interval to avoid never updating the dataset if the `lastFilterSetUpdateDate` is mistakenly set in the far future
        abs(dateProvider().timeIntervalSince(updateManager.lastFilterSetUpdateDate)) > .minutes(featureFlagger.filterSetUpdateFrequency)
    }

    private var canFetchDatasets: Bool {
        featureFlagger.isMaliciousSiteProtectionEnabled && userPreferencesManager.isMaliciousSiteProtectionOn
    }

    init(
        updateManager: MaliciousSiteUpdateManaging,
        featureFlagger: MaliciousSiteProtectionFeatureFlagger & MaliciousSiteProtectionFeatureFlagsSettingsProvider,
        userPreferencesManager: MaliciousSiteProtectionPreferencesProvider,
        dateProvider: @escaping () -> Date = Date.init,
        backgroundTaskScheduler: BGTaskScheduling = BGTaskScheduler.shared,
        application: BackgroundRefreshCapable = UIApplication.shared
    ) {
        self.updateManager = updateManager
        self.featureFlagger = featureFlagger
        self.userPreferencesManager = userPreferencesManager
        self.dateProvider = dateProvider
        self.backgroundTaskScheduler = backgroundTaskScheduler
        self.application = application
    }
}

// MARK: - Public

extension MaliciousSiteProtectionDatasetsFetcher {

    func startFetching() {
        guard canFetchDatasets else { return }

        Logger.MaliciousSiteProtection.datasetsFetcher.debug("Feature is On and Enabled in App Settings")

        // If hashPrefix Sets need to be updated fetch them
        if shouldUpdateHashPrefixSets {
            Logger.MaliciousSiteProtection.datasetsFetcher.debug("Downloading HashPrefixSets")
            _ = updateManager.updateData(datasetType: .hashPrefixSet)
        }

        // If hashPrefix Sets need to be updated fetch them
        if shouldUpdateFilterSets {
            Logger.MaliciousSiteProtection.datasetsFetcher.debug("Downloading FilterSets")
            _ = updateManager.updateData(datasetType: .filterSet)
        }
    }

}

// MARK: - Private

private extension MaliciousSiteProtectionDatasetsFetcher {

    func setupBindings() {
        guard featureFlagger.isMaliciousSiteProtectionEnabled else { return }
        subscribeToDetectionPreferences()
    }

    func subscribeToDetectionPreferences() {
        let isMaliciousSiteProtectionOn = userPreferencesManager.isMaliciousSiteProtectionOn

        preferencesManagerCancellable = userPreferencesManager
            .isMaliciousSiteProtectionOnPublisher
            .scan((previous: isMaliciousSiteProtectionOn, current: isMaliciousSiteProtectionOn)) { accumulated, newValue in // Get the previous value of the publisher
                (accumulated.current, newValue)
            }
            .sink { [weak self] isOnInfo in
                self?.handleUserPreferencesChange(wasOn: isOnInfo.previous, isOn: isOnInfo.current)
            }
    }

    func handleUserPreferencesChange(wasOn: Bool, isOn: Bool) {
        // If the feature is turned off in the user Preferences when we launch the App we don't need to stop background tasks.
        // If the feature was turned off and the user turns it on we want to download the datasets and schedule the background tasks.
        // If the feature is turned on when in the user Preferences when we launch the App we want to schedule the background tasks as we already started fetching the datasets on App launch.
        // If the feature was turned on and the user turns it off we want to cancel the background tasks.
        switch (wasOn, isOn) {
        case (false, false):
            break
        case (true, true):
            // Start only background tasks
            scheduleBackgroundTasksIfNeeded()
        case (false, true):
            // Start downloading and initiate background tasks
            startUpdateTasks()
        case (true, false):
            stopUpdateTasks()
        }
    }

    func startUpdateTasks() {
        startFetching()
        scheduleBackgroundTasksIfNeeded()
    }

    func scheduleBackgroundTasksIfNeeded() {
        guard application.backgroundRefreshStatus == .available else {
            Logger.MaliciousSiteProtection.datasetsFetcher.debug("Skipping scheduling background tasks as App does not support background refresh.")
            return
        }

        backgroundTaskScheduler.getPendingTaskRequests { [weak self] tasks in
            guard let self else { return }

            DataManager.StoredDataType.Kind.allCases.forEach { datasetType in
                // BackgroundTasks will automatically replace an existing task in the queue if one with the same identifier is queued, so we should only
                // schedule a task if there are none pending in order to avoid the config task getting perpetually replaced.
                guard !tasks.contains(where: { $0.identifier == datasetType.backgroundTaskIdentifier }) else {
                    Logger.MaliciousSiteProtection.datasetsFetcher.debug("Skipping scheduling background tasks for \(datasetType.rawValue)")
                    return
                }
                self.scheduleBackgroundRefreshTask(datasetType: datasetType)
            }
        }
    }

    func stopUpdateTasks() {
        // Cancel scheduled background tasks
        DataManager.StoredDataType.Kind.allCases.forEach {
            backgroundTaskScheduler.cancel(taskRequestWithIdentifier: $0.backgroundTaskIdentifier)
        }
    }

    func refreshInterval(for datasetsType: DataManager.StoredDataType.Kind) -> TimeInterval {
        switch datasetsType {
        case .hashPrefixSet:
            return .minutes(featureFlagger.hashPrefixUpdateFrequency)
        case .filterSet:
            return .minutes(featureFlagger.filterSetUpdateFrequency)
        }
    }

    func shouldRefresh(datasetType: DataManager.StoredDataType.Kind) -> Bool {
        switch datasetType {
        case .hashPrefixSet:
            shouldUpdateHashPrefixSets
        case .filterSet:
            shouldUpdateFilterSets
        }
    }

    func backgroundRefreshTaskHandler(backgroundTask: BGTaskInterface, datasetType: DataManager.StoredDataType.Kind) {
        let fetchAndProcessDatasetTask = Task {
            if canFetchDatasets {
                _ = updateManager.updateData(datasetType: datasetType)
            }
            scheduleBackgroundRefreshTask(datasetType: datasetType)
            backgroundTask.setTaskCompleted(success: true)
        }

        backgroundTask.expirationHandler = {
            fetchAndProcessDatasetTask.cancel()
            backgroundTask.setTaskCompleted(success: false)
        }
    }

}

// MARK: - Background Tasks

extension MaliciousSiteProtectionDatasetsFetcher {

    func registerBackgroundRefreshTaskHandler() {
        DataManager.StoredDataType.Kind.allCases.forEach { datasetType in
            backgroundTaskScheduler.register(forTaskWithIdentifier: datasetType.backgroundTaskIdentifier) { [weak self] backgroundTask in
                guard let self else { return }

                guard shouldRefresh(datasetType: datasetType) else {
                    backgroundTask.setTaskCompleted(success: true)
                    scheduleBackgroundRefreshTask(datasetType: datasetType)
                    return
                }

                backgroundRefreshTaskHandler(backgroundTask: backgroundTask, datasetType: datasetType)
            }
        }

        setupBindings()
    }

    private func scheduleBackgroundRefreshTask(datasetType: DataManager.StoredDataType.Kind) {
        func performScheduleTasks() {
            do {
                Logger.MaliciousSiteProtection.datasetsFetcher.debug("Scheduling background task for \(datasetType.rawValue)")
                try backgroundTaskScheduler.submit(task)
            } catch {
                Logger.MaliciousSiteProtection.datasetsFetcher.error("Failed scheduling background task for \(datasetType.rawValue)")
                Pixel.fire(pixel: .backgroundTaskSubmissionFailed, error: error, withAdditionalParameters: [PixelParameters.backgroundTaskCategory: "maliciousSiteProtection"])
            }
        }

        guard canFetchDatasets else { return }

        let task = BGProcessingTaskRequest(identifier: datasetType.backgroundTaskIdentifier)
        task.requiresNetworkConnectivity = true
        task.earliestBeginDate = Date(timeIntervalSinceNow: refreshInterval(for: datasetType))

        // Background tasks can be debugged by breaking on the `submit` call, stepping over, then running the following LLDB command, before resuming:
        //
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.duckduckgo.app.maliciousSiteProtectionHashPrefixSetRefresh"]
        //
        // Task expiration can be simulated similarly:
        //
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"com.duckduckgo.app.maliciousSiteProtectionHashPrefixSetRefresh"]

        #if targetEnvironment(simulator)
        guard ProcessInfo().arguments.contains("testing") else { return }
        performScheduleTasks()
        #else
        performScheduleTasks()
        #endif
    }

}

// MARK: - DataManager.StoredDataType.Kind + Background Tasks

extension DataManager.StoredDataType.Kind {

    var backgroundTaskIdentifier: String {
        switch self {
        case .hashPrefixSet: return "com.duckduckgo.app.maliciousSiteProtectionHashPrefixSetRefresh"
        case .filterSet: return "com.duckduckgo.app.maliciousSiteProtectionFilterSetRefresh"
        }
    }

}

// MARK: - Background Tasks + Testing

protocol BGTaskInterface: AnyObject {
    var identifier: String { get }
    var expirationHandler: (() -> Void)? { get set }

    func setTaskCompleted(success: Bool)
}

extension BGTask: BGTaskInterface {}

protocol BGTaskScheduling: AnyObject {
    @discardableResult
    func register(forTaskWithIdentifier identifier: String, launchHandler: @escaping (BGTaskInterface) -> Void) -> Bool
    func submit(_ taskRequest: BGTaskRequest) throws
    func cancel(taskRequestWithIdentifier identifier: String)
    func getPendingTaskRequests(completionHandler: @escaping ([BGTaskRequest]) -> Void)
    func pendingTaskRequests() async -> [BGTaskRequest]
}

extension BGTaskScheduler: BGTaskScheduling {
    func register(forTaskWithIdentifier identifier: String, launchHandler: @escaping (any BGTaskInterface) -> Void) -> Bool {
        register(forTaskWithIdentifier: identifier, using: nil, launchHandler: launchHandler)
    }
}

protocol BackgroundRefreshCapable: AnyObject {
    var backgroundRefreshStatus: UIBackgroundRefreshStatus { get }
}

extension UIApplication: BackgroundRefreshCapable {}
