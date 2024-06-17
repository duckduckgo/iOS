//
//  RemoteMessaging.swift
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

import Common
import Foundation
import Core
import BackgroundTasks
import BrowserServicesKit
import Persistence
import Bookmarks
import RemoteMessaging
import NetworkProtection
import Subscription

struct RemoteMessaging {

    struct Notifications {
        static let remoteMessagesDidChange = Notification.Name("com.duckduckgo.app.RemoteMessagesDidChange")
    }

    @UserDefaultsWrapper(key: .lastRemoteMessagingRefreshDate, defaultValue: .distantPast)
    static private var lastRemoteMessagingRefreshDate: Date

    struct Constants {
        static let backgroundRefreshTaskIdentifier = "com.duckduckgo.app.remoteMessageRefresh"
        static let minimumConfigurationRefreshInterval: TimeInterval = 60 * 60 * 4
    }

    static private var shouldRefresh: Bool {
        return Date().timeIntervalSince(Self.lastRemoteMessagingRefreshDate) > Constants.minimumConfigurationRefreshInterval
    }

    static func registerBackgroundRefreshTaskHandler(
        bookmarksDatabase: CoreDataDatabase,
        favoritesDisplayMode: @escaping @autoclosure () -> FavoritesDisplayMode
    ) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.backgroundRefreshTaskIdentifier, using: nil) { task in
            guard shouldRefresh else {
                task.setTaskCompleted(success: true)
                scheduleBackgroundRefreshTask()
                return
            }
            backgroundRefreshTaskHandler(bgTask: task, bookmarksDatabase: bookmarksDatabase, favoritesDisplayMode: favoritesDisplayMode())
        }
    }

    static func scheduleBackgroundRefreshTask() {
        let task = BGProcessingTaskRequest(identifier: Constants.backgroundRefreshTaskIdentifier)
        task.earliestBeginDate = Date(timeIntervalSinceNow: Constants.minimumConfigurationRefreshInterval)
        task.requiresNetworkConnectivity = true

        // Background tasks can be debugged by breaking on the `submit` call, stepping over, then running the following LLDB command, before resuming:
        //
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.duckduckgo.app.remoteMessageRefresh"]
        //
        // Task expiration can be simulated similarly:
        //
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"com.duckduckgo.app.remoteMessageRefresh"]

        #if !targetEnvironment(simulator)
        do {
            try BGTaskScheduler.shared.submit(task)
        } catch {
            os_log("Failed to schedule background task: %@", log: OSLog.remoteMessaging, type: .error, error.localizedDescription)
        }
        #endif
    }

    static func backgroundRefreshTaskHandler(
        bgTask: BGTask,
        bookmarksDatabase: CoreDataDatabase,
        favoritesDisplayMode: @escaping @autoclosure () -> FavoritesDisplayMode
    ) {
        let fetchAndProcessTask = Task {
            do {
                try await Self.fetchAndProcess(bookmarksDatabase: bookmarksDatabase, favoritesDisplayMode: favoritesDisplayMode())
                Self.lastRemoteMessagingRefreshDate = Date()
                scheduleBackgroundRefreshTask()
                bgTask.setTaskCompleted(success: true)
            } catch {
                scheduleBackgroundRefreshTask()
                bgTask.setTaskCompleted(success: false)
            }
        }

        bgTask.expirationHandler = {
            fetchAndProcessTask.cancel()
            bgTask.setTaskCompleted(success: false)
        }
    }

    /// Convenience function
    static func fetchAndProcess(bookmarksDatabase: CoreDataDatabase, favoritesDisplayMode: FavoritesDisplayMode) async throws {
        
        var bookmarksCount = 0
        var favoritesCount = 0
        let context = bookmarksDatabase.makeContext(concurrencyType: .privateQueueConcurrencyType)
        context.performAndWait {
            let displayedFavoritesFolder = BookmarkUtils.fetchFavoritesFolder(withUUID: favoritesDisplayMode.displayedFolder.rawValue, in: context)!

            let bookmarksCountRequest = BookmarkEntity.fetchRequest()
            bookmarksCountRequest.predicate = NSPredicate(
                format: "SUBQUERY(%K, $x, $x CONTAINS %@).@count == 0 AND %K == false AND %K == false AND (%K == NO OR %K == nil)",
                #keyPath(BookmarkEntity.favoriteFolders),
                displayedFavoritesFolder,
                #keyPath(BookmarkEntity.isFolder),
                #keyPath(BookmarkEntity.isPendingDeletion),
                #keyPath(BookmarkEntity.isStub), #keyPath(BookmarkEntity.isStub))
            bookmarksCount = (try? context.count(for: bookmarksCountRequest)) ?? 0

            let favoritesCountRequest = BookmarkEntity.fetchRequest()
            favoritesCountRequest.predicate = NSPredicate(format: "%K CONTAINS %@ AND %K == false AND %K == false AND (%K == NO OR %K == nil)",
                                                          #keyPath(BookmarkEntity.favoriteFolders),
                                                          displayedFavoritesFolder,
                                                          #keyPath(BookmarkEntity.isFolder),
                                                          #keyPath(BookmarkEntity.isPendingDeletion),
                                                          #keyPath(BookmarkEntity.isStub), #keyPath(BookmarkEntity.isStub))
            favoritesCount = (try? context.count(for: favoritesCountRequest)) ?? 0
        }
        
        let isWidgetInstalled = await AppDependencyProvider.shared.appSettings.isWidgetInstalled()

        try await Self.fetchAndProcess(bookmarksCount: bookmarksCount,
                                       favoritesCount: favoritesCount,
                                       isWidgetInstalled: isWidgetInstalled)
    }

    // swiftlint:disable:next function_body_length
    static private func fetchAndProcess(bookmarksCount: Int,
                                        favoritesCount: Int,
                                        remoteMessagingStore: RemoteMessagingStore = AppDependencyProvider.shared.remoteMessagingStore,
                                        statisticsStore: StatisticsStore = StatisticsUserDefaults(),
                                        variantManager: VariantManager = DefaultVariantManager(),
                                        isWidgetInstalled: Bool) async throws {

        let result = await Self.fetchRemoteMessages(remoteMessageRequest: RemoteMessageRequest())

        switch result {
        case .success(let statusResponse):
            os_log("Successfully fetched remote messages", log: .remoteMessaging, type: .debug)

            let isPrivacyProSubscriber = AppDependencyProvider.shared.subscriptionManager.accountManager.isUserAuthenticated
            let canPurchase = AppDependencyProvider.shared.subscriptionManager.canPurchase

            let activationDateStore = DefaultVPNActivationDateStore()
            let daysSinceNetworkProtectionEnabled = activationDateStore.daysSinceActivation() ?? -1

            var privacyProDaysSinceSubscribed: Int = -1
            var privacyProDaysUntilExpiry: Int = -1
            var privacyProPurchasePlatform: String?
            var privacyProIsActive: Bool = false
            var privacyProIsExpiring: Bool = false
            var privacyProIsExpired: Bool = false
            let surveyActionMapper: DefaultRemoteMessagingSurveyURLBuilder

            if let accessToken = AppDependencyProvider.shared.subscriptionManager.accountManager.accessToken {
                let subscriptionResult = await AppDependencyProvider.shared.subscriptionManager.subscriptionService.getSubscription(
                    accessToken: accessToken
                )

                if case let .success(subscription) = subscriptionResult {
                    privacyProDaysSinceSubscribed = Calendar.current.numberOfDaysBetween(subscription.startedAt, and: Date()) ?? -1
                    privacyProDaysUntilExpiry = Calendar.current.numberOfDaysBetween(Date(), and: subscription.expiresOrRenewsAt) ?? -1
                    privacyProPurchasePlatform = subscription.platform.rawValue

                    switch subscription.status {
                    case .autoRenewable, .gracePeriod:
                        privacyProIsActive = true
                    case .notAutoRenewable:
                        privacyProIsActive = true
                        privacyProIsExpiring = true
                    case .expired, .inactive:
                        privacyProIsExpired = true
                    case .unknown:
                        break // Not supported in RMF
                    }

                    surveyActionMapper = DefaultRemoteMessagingSurveyURLBuilder(statisticsStore: statisticsStore, subscription: subscription)
                } else {
                    surveyActionMapper = DefaultRemoteMessagingSurveyURLBuilder(statisticsStore: statisticsStore, subscription: nil)
                }
            } else {
                surveyActionMapper = DefaultRemoteMessagingSurveyURLBuilder(statisticsStore: statisticsStore, subscription: nil)
            }

            let dismissedMessageIds = remoteMessagingStore.fetchDismissedRemoteMessageIds()

            let remoteMessagingConfigMatcher = RemoteMessagingConfigMatcher(
                appAttributeMatcher: AppAttributeMatcher(statisticsStore: statisticsStore,
                                                         variantManager: variantManager,
                                                         isInternalUser: AppDependencyProvider.shared.internalUserDecider.isInternalUser),
                userAttributeMatcher: UserAttributeMatcher(statisticsStore: statisticsStore,
                                                           variantManager: variantManager,
                                                           bookmarksCount: bookmarksCount,
                                                           favoritesCount: favoritesCount,
                                                           appTheme: AppUserDefaults().currentThemeName.rawValue,
                                                           isWidgetInstalled: isWidgetInstalled,
                                                           daysSinceNetPEnabled: daysSinceNetworkProtectionEnabled,
                                                           isPrivacyProEligibleUser: canPurchase,
                                                           isPrivacyProSubscriber: isPrivacyProSubscriber,
                                                           privacyProDaysSinceSubscribed: privacyProDaysSinceSubscribed,
                                                           privacyProDaysUntilExpiry: privacyProDaysUntilExpiry,
                                                           privacyProPurchasePlatform: privacyProPurchasePlatform,
                                                           isPrivacyProSubscriptionActive: privacyProIsActive,
                                                           isPrivacyProSubscriptionExpiring: privacyProIsExpiring,
                                                           isPrivacyProSubscriptionExpired: privacyProIsExpired,
                                                           dismissedMessageIds: dismissedMessageIds),
                percentileStore: RemoteMessagingPercentileUserDefaultsStore(userDefaults: .standard),
                surveyActionMapper: surveyActionMapper,
                dismissedMessageIds: dismissedMessageIds
            )

            let processor = RemoteMessagingConfigProcessor(remoteMessagingConfigMatcher: remoteMessagingConfigMatcher)
            let config = remoteMessagingStore.fetchRemoteMessagingConfig()

            if let processorResult = processor.process(jsonRemoteMessagingConfig: statusResponse,
                                                       currentConfig: config) {
                remoteMessagingStore.saveProcessedResult(processorResult)
            }
        case .failure(let error):
            os_log("Failed to fetch remote messages", log: .remoteMessaging, type: .error)
            throw error
        }
    }

    static func fetchRemoteMessages(remoteMessageRequest: RemoteMessageRequest) async -> Result<RemoteMessageResponse.JsonRemoteMessagingConfig, RemoteMessageResponse.StatusError> {
        return await withCheckedContinuation { continuation in
            remoteMessageRequest.getRemoteMessage(completionHandler: { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: .success(response))
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            })
        }
    }
}
