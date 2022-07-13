//
//  AppConfigurationFetch.swift
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
import BackgroundTasks
import Core
import os.log
import BrowserServicesKit

public typealias AppConfigurationCompletion = (Bool) -> Void

protocol CompletableTask {

    func setTaskCompleted(success: Bool)

}

extension BGTask: CompletableTask { }

protocol AppConfigurationFetchStatistics {
    var foregroundStartCount: Int { get set }
    var foregroundNoDataCount: Int { get set }
    var foregroundNewDataCount: Int { get set }
    
    var backgroundStartCount: Int { get set }
    var backgroundNoDataCount: Int { get set }
    var backgroundNewDataCount: Int { get set }

    var backgroundFetchTaskExpirationCount: Int { get set }
}

class AppConfigurationFetch {
    
    struct Constants {
        static let backgroundTaskName = "Fetch Configuration Task"
        static let backgroundProcessingTaskIdentifier = "com.duckduckgo.app.configurationRefresh"
        static let minimumConfigurationRefreshInterval: TimeInterval = 60 * 30
    }
    
    private struct Keys {
        static let bgFetchType = "bgft"
        static let bgFetchTypeBackgroundTasks = "bgbt"
        static let bgFetchTaskExpiration = "bgte"
        static let bgFetchTaskDuration = "bgtd"
        static let bgFetchStart = "bgfs"
        static let bgFetchNoData = "bgnd"
        static let bgFetchWithData = "bgwd"
        static let fgFetchStart = "fgfs"
        static let fgFetchNoData = "fgnd"
        static let fgFetchWithData = "fgwd"

        static let fetchHTTPSBloomFilterSpec = "d1"
        static let fetchHTTPSBloomFilter = "d2"
        static let fetchHTTPSExcludedDomainsCount = "d3"
        static let fetchSurrogatesCount = "d4"
        static let fetchTrackerDataSetCount = "d5"
        static let fetchPrivacyConfigurationCount = "d7"
    }
    
    private static let fetchQueue = DispatchQueue(label: "Config Fetch queue", qos: .utility)

    @UserDefaultsWrapper(key: .lastConfigurationRefreshDate, defaultValue: .distantPast)
    static private var lastConfigurationRefreshDate: Date

    @UserDefaultsWrapper(key: .backgroundFetchTaskDuration, defaultValue: 0)
    static private var backgroundFetchTaskDuration: Int
    
    @UserDefaultsWrapper(key: .downloadedHTTPSBloomFilterSpecCount, defaultValue: 0)
    private var downloadedHTTPSBloomFilterSpecCount: Int
    
    @UserDefaultsWrapper(key: .downloadedHTTPSBloomFilterCount, defaultValue: 0)
    private var downloadedHTTPSBloomFilterCount: Int

    @UserDefaultsWrapper(key: .downloadedHTTPSExcludedDomainsCount, defaultValue: 0)
    private var downloadedHTTPSExcludedDomainsCount: Int

    @UserDefaultsWrapper(key: .downloadedSurrogatesCount, defaultValue: 0)
    private var downloadedSurrogatesCount: Int

    @UserDefaultsWrapper(key: .downloadedTrackerDataSetCount, defaultValue: 0)
    private var downloadedTrackerDataSetCount: Int
    
    @UserDefaultsWrapper(key: .downloadedPrivacyConfigurationCount, defaultValue: 0)
    private var downloadedPrivacyConfigurationCount: Int

    static private var shouldRefresh: Bool {
        return Date().timeIntervalSince(Self.lastConfigurationRefreshDate) > Constants.minimumConfigurationRefreshInterval
    }

    enum BackgroundRefreshCompletionStatus {
        case expired
        case noData
        case newData

        var success: Bool {
            self != .expired
        }
    }
    
    func start(isBackgroundFetch: Bool = false,
               completion: AppConfigurationCompletion?) {
        guard Self.shouldRefresh else {
            // Statistics are not sent after a successful background refresh in order to reduce the time spent in the background, so they are checked
            // here in case a background refresh has happened recently.
            Self.fetchQueue.async {
                self.sendStatistics {
                    completion?(false)
                }
            }

            return
        }

        type(of: self).fetchQueue.async {
            let taskID = UIApplication.shared.beginBackgroundTask(withName: Constants.backgroundTaskName)
            let fetchedNewData = self.fetchConfigurationFiles(isBackground: isBackgroundFetch)

            if !isBackgroundFetch {
                type(of: self).fetchQueue.async {
                    self.sendStatistics {
                        UIApplication.shared.endBackgroundTask(taskID)
                    }
                }
            } else {
                UIApplication.shared.endBackgroundTask(taskID)
            }

            completion?(fetchedNewData)
        }
    }

    static func registerBackgroundRefreshTaskHandler() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.backgroundProcessingTaskIdentifier, using: nil) { (task) in
            guard shouldRefresh else {
                task.setTaskCompleted(success: true)
                scheduleBackgroundRefreshTask()
                return
            }

            let store = AppUserDefaults()
            let fetcher = AppConfigurationFetch()
            backgroundRefreshTaskHandler(store: store, configurationFetcher: fetcher, queue: fetchQueue, task: task)
        }
    }

    static func scheduleBackgroundRefreshTask() {
        let task = BGProcessingTaskRequest(identifier: AppConfigurationFetch.Constants.backgroundProcessingTaskIdentifier)
        task.requiresNetworkConnectivity = true
        task.earliestBeginDate = Date(timeIntervalSinceNow: Constants.minimumConfigurationRefreshInterval)

        // Background tasks can be debugged by breaking on the `submit` call, stepping over, then running the following LLDB command, before resuming:
        //
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.duckduckgo.app.configurationRefresh"]
        //
        // Task expiration can be simulated similarly:
        //
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"com.duckduckgo.app.configurationRefresh"]

        #if !targetEnvironment(simulator)
        do {
            try BGTaskScheduler.shared.submit(task)
        } catch {
            Pixel.fire(pixel: .backgroundTaskSubmissionFailed, error: error)
        }
        #endif
    }

    @discardableResult
    private func fetchConfigurationFiles(isBackground: Bool) -> Bool {
        self.markFetchStarted(isBackground: isBackground)

        var newData = false
        let semaphore = DispatchSemaphore(value: 0)

        AppDependencyProvider.shared.storageCache.update(progress: updateFetchProgress) { newCache in
            newData = newData || (newCache != nil)
            semaphore.signal()
        }

        semaphore.wait()

        self.markFetchCompleted(isBackground: isBackground, hasNewData: newData)
        return newData
    }
    
    private func markFetchStarted(isBackground: Bool) {
        var store: AppConfigurationFetchStatistics = AppUserDefaults()
        
        if isBackground {
            store.backgroundStartCount += 1
        } else {
            store.foregroundStartCount += 1
        }
    }

    private func updateFetchProgress(configuration: ContentBlockerRequest.Configuration) {
        switch configuration {
        case .httpsBloomFilter: downloadedHTTPSBloomFilterCount += 1
        case .httpsBloomFilterSpec: downloadedHTTPSBloomFilterSpecCount += 1
        case .httpsExcludedDomains: downloadedHTTPSExcludedDomainsCount += 1
        case .surrogates: downloadedSurrogatesCount += 1
        case .trackerDataSet: downloadedTrackerDataSetCount += 1
        case .privacyConfiguration: downloadedPrivacyConfigurationCount += 1
        }
    }
    
    private func markFetchCompleted(isBackground: Bool, hasNewData: Bool) {
        var store: AppConfigurationFetchStatistics = AppUserDefaults()
        
        if isBackground {
            if hasNewData {
                store.backgroundNewDataCount += 1
            } else {
                store.backgroundNoDataCount += 1
            }
        } else {
            if hasNewData {
                store.foregroundNewDataCount += 1
            } else {
                store.foregroundNoDataCount += 1
            }
        }

        Self.lastConfigurationRefreshDate = Date()
    }
    
    private func sendStatistics(completion: () -> Void ) {
        let store: AppConfigurationFetchStatistics = AppUserDefaults()
        guard store.foregroundStartCount > 0 || store.backgroundStartCount > 0 else {
            completion()
            return
        }

        let backgroundFetchType = Keys.bgFetchTypeBackgroundTasks

        let parameters = [Keys.bgFetchStart: String(store.backgroundStartCount),
                          Keys.bgFetchNoData: String(store.backgroundNoDataCount),
                          Keys.bgFetchWithData: String(store.backgroundNewDataCount),
                          Keys.fgFetchStart: String(store.foregroundStartCount),
                          Keys.fgFetchNoData: String(store.foregroundNoDataCount),
                          Keys.fgFetchWithData: String(store.foregroundNewDataCount),
                          Keys.bgFetchType: backgroundFetchType,
                          Keys.bgFetchTaskExpiration: String(store.backgroundFetchTaskExpirationCount),
                          Keys.bgFetchTaskDuration: String(Self.backgroundFetchTaskDuration),
                          Keys.fetchHTTPSBloomFilterSpec: String(downloadedHTTPSBloomFilterSpecCount),
                          Keys.fetchHTTPSBloomFilter: String(downloadedHTTPSBloomFilterCount),
                          Keys.fetchHTTPSExcludedDomainsCount: String(downloadedHTTPSExcludedDomainsCount),
                          Keys.fetchSurrogatesCount: String(downloadedSurrogatesCount),
                          Keys.fetchTrackerDataSetCount: String(downloadedTrackerDataSetCount),
                          Keys.fetchPrivacyConfigurationCount: String(downloadedPrivacyConfigurationCount)]
        
        let semaphore = DispatchSemaphore(value: 0)
        
        Pixel.fire(pixel: .configurationFetchInfo, withAdditionalParameters: parameters) { error in
            guard error == nil else {
                semaphore.signal()
                return
            }

            self.resetStatistics()
            semaphore.signal()
        }
        
        semaphore.wait()
        completion()
    }
    
    private func resetStatistics() {
        var store: AppConfigurationFetchStatistics = AppUserDefaults()
        
        store.backgroundStartCount = 0
        store.backgroundNoDataCount = 0
        store.backgroundNewDataCount = 0
        store.foregroundStartCount = 0
        store.foregroundNoDataCount = 0
        store.foregroundNewDataCount = 0
        store.backgroundFetchTaskExpirationCount = 0

        Self.backgroundFetchTaskDuration = 0

        downloadedHTTPSBloomFilterCount = 0
        downloadedHTTPSBloomFilterSpecCount = 0
        downloadedHTTPSExcludedDomainsCount = 0
        downloadedSurrogatesCount = 0
        downloadedTrackerDataSetCount = 0
        downloadedPrivacyConfigurationCount = 0
    }
}

extension AppConfigurationFetch {

    static func backgroundRefreshTaskHandler(store: AppConfigurationFetchStatistics,
                                             configurationFetcher: AppConfigurationFetch,
                                             queue: DispatchQueue,
                                             task: BGTask) {

        let refreshStartDate = Date()
        var lastCompletionStatus: BackgroundRefreshCompletionStatus?

        task.expirationHandler = {
            DispatchQueue.main.async {
                if lastCompletionStatus == nil {
                    var mutableStore = store
                    mutableStore.backgroundFetchTaskExpirationCount += 1
                }

                lastCompletionStatus = backgroundRefreshTaskCompletionHandler(store: store,
                                                                              refreshStartDate: refreshStartDate,
                                                                              task: task,
                                                                              status: .expired,
                                                                              previousStatus: lastCompletionStatus)
            }
        }

        queue.async {
            let fetchedNewData = configurationFetcher.fetchConfigurationFiles(isBackground: true)
            ContentBlocking.shared.contentBlockingManager.scheduleCompilation()

            DispatchQueue.main.async {
                lastCompletionStatus = backgroundRefreshTaskCompletionHandler(store: store,
                                                                              refreshStartDate: refreshStartDate,
                                                                              task: task,
                                                                              status: fetchedNewData ? .newData : .noData,
                                                                              previousStatus: lastCompletionStatus)
            }
        }
    }

    // Gets called at the end of the refresh process, either by the task being expired by the OS or by the refresh process completing successfully.
    // It checks whether it has been called earlier in the same refresh run and self-corrects the completion statistics if necessary.
    static func backgroundRefreshTaskCompletionHandler(store: AppConfigurationFetchStatistics,
                                                       refreshStartDate: Date,
                                                       task: CompletableTask,
                                                       status: BackgroundRefreshCompletionStatus,
                                                       previousStatus: BackgroundRefreshCompletionStatus?) -> BackgroundRefreshCompletionStatus {

        task.setTaskCompleted(success: status.success)
        scheduleBackgroundRefreshTask()

        let refreshEndDate = Date()
        let difference = refreshEndDate.timeIntervalSince(refreshStartDate)
        backgroundFetchTaskDuration += Int(difference)

        // This function tries to avoid expirations that are counted erroneously, so in the case where an expiration comes in _just_ before the
        // refresh process completes it checks if an expiration was last processed and decrements the expiration counter so that the books balance.
        if previousStatus == .expired {
            var mutableStore = store
            mutableStore.backgroundFetchTaskExpirationCount = max(0, store.backgroundFetchTaskExpirationCount - 1)
        }

        return status
    }

}
