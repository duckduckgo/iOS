//
//  RemoteMessagingClient.swift
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

final class RemoteMessagingConfigMatcherProvider: RemoteMessagingConfigMatcherProviding {

    init(
        bookmarksDatabase: CoreDataDatabase,
        appSettings: AppSettings,
        internalUserDecider: InternalUserDecider
    ) {
        self.bookmarksDatabase = bookmarksDatabase
        self.appSettings = appSettings
        self.internalUserDecider = internalUserDecider
    }

    let bookmarksDatabase: CoreDataDatabase
    let appSettings: AppSettings
    let internalUserDecider: InternalUserDecider

    // swiftlint:disable:next function_body_length
    func refreshConfigMatcher(with store: RemoteMessagingStoring) async -> RemoteMessagingConfigMatcher {

        var bookmarksCount = 0
        var favoritesCount = 0
        let context = bookmarksDatabase.makeContext(concurrencyType: .privateQueueConcurrencyType)
        context.performAndWait {
            bookmarksCount = BookmarkUtils.numberOfBookmarks(in: context)
            favoritesCount = BookmarkUtils.numberOfFavorites(for: appSettings.favoritesDisplayMode, in: context)
        }

        let statisticsStore = StatisticsUserDefaults()
        let variantManager = DefaultVariantManager()
        let subscriptionManager = AppDependencyProvider.shared.subscriptionManager

        let isPrivacyProSubscriber = subscriptionManager.accountManager.isUserAuthenticated
        let isPrivacyProEligibleUser = subscriptionManager.canPurchase

        let activationDateStore = DefaultVPNActivationDateStore()
        let daysSinceNetworkProtectionEnabled = activationDateStore.daysSinceActivation() ?? -1

        var privacyProDaysSinceSubscribed: Int = -1
        var privacyProDaysUntilExpiry: Int = -1
        var privacyProPurchasePlatform: String?
        var isPrivacyProSubscriptionActive: Bool = false
        var isPrivacyProSubscriptionExpiring: Bool = false
        var isPrivacyProSubscriptionExpired: Bool = false
        let surveyActionMapper: DefaultRemoteMessagingSurveyURLBuilder

        if let accessToken = subscriptionManager.accountManager.accessToken {
            let subscriptionResult = await subscriptionManager.subscriptionEndpointService.getSubscription(
                accessToken: accessToken
            )

            if case let .success(subscription) = subscriptionResult {
                privacyProDaysSinceSubscribed = Calendar.current.numberOfDaysBetween(subscription.startedAt, and: Date()) ?? -1
                privacyProDaysUntilExpiry = Calendar.current.numberOfDaysBetween(Date(), and: subscription.expiresOrRenewsAt) ?? -1
                privacyProPurchasePlatform = subscription.platform.rawValue

                switch subscription.status {
                case .autoRenewable, .gracePeriod:
                    isPrivacyProSubscriptionActive = true
                case .notAutoRenewable:
                    isPrivacyProSubscriptionActive = true
                    isPrivacyProSubscriptionExpiring = true
                case .expired, .inactive:
                    isPrivacyProSubscriptionExpired = true
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

        let dismissedMessageIds = store.fetchDismissedRemoteMessageIds()

        return RemoteMessagingConfigMatcher(
            appAttributeMatcher: AppAttributeMatcher(statisticsStore: statisticsStore,
                                                     variantManager: variantManager,
                                                     isInternalUser: internalUserDecider.isInternalUser),
            userAttributeMatcher: UserAttributeMatcher(statisticsStore: statisticsStore,
                                                       variantManager: variantManager,
                                                       bookmarksCount: bookmarksCount,
                                                       favoritesCount: favoritesCount,
                                                       appTheme: appSettings.currentThemeName.rawValue,
                                                       isWidgetInstalled: await appSettings.isWidgetInstalled(),
                                                       daysSinceNetPEnabled: daysSinceNetworkProtectionEnabled,
                                                       isPrivacyProEligibleUser: isPrivacyProEligibleUser,
                                                       isPrivacyProSubscriber: isPrivacyProSubscriber,
                                                       privacyProDaysSinceSubscribed: privacyProDaysSinceSubscribed,
                                                       privacyProDaysUntilExpiry: privacyProDaysUntilExpiry,
                                                       privacyProPurchasePlatform: privacyProPurchasePlatform,
                                                       isPrivacyProSubscriptionActive: isPrivacyProSubscriptionActive,
                                                       isPrivacyProSubscriptionExpiring: isPrivacyProSubscriptionExpiring,
                                                       isPrivacyProSubscriptionExpired: isPrivacyProSubscriptionExpired,
                                                       dismissedMessageIds: dismissedMessageIds),
            percentileStore: RemoteMessagingPercentileUserDefaultsStore(userDefaults: .standard),
            surveyActionMapper: surveyActionMapper,
            dismissedMessageIds: dismissedMessageIds
        )
    }
}

final class RemoteMessagingClient: RemoteMessagingClientBase {

    private static let endpoint: URL = {
#if DEBUG
        URL(string: "https://raw.githubusercontent.com/duckduckgo/remote-messaging-config/main/samples/ios/sample1.json")!
#else
        URL(string: "https://staticcdn.duckduckgo.com/remotemessaging/config/v1/ios-config.json")!
#endif
    }()

    init(
        bookmarksDatabase: CoreDataDatabase,
        appSettings: AppSettings,
        internalUserDecider: InternalUserDecider
    ) {
        self.bookmarksDatabase = bookmarksDatabase
        self.appSettings = appSettings
        self.internalUserDecider = internalUserDecider

        let provider = RemoteMessagingConfigMatcherProvider(
            bookmarksDatabase: bookmarksDatabase,
            appSettings: appSettings,
            internalUserDecider: internalUserDecider
        )
        super.init(endpoint: Self.endpoint, configMatcherProvider: provider)
    }
    private let bookmarksDatabase: CoreDataDatabase
    private let appSettings: AppSettings
    private let internalUserDecider: InternalUserDecider

    @UserDefaultsWrapper(key: .lastRemoteMessagingRefreshDate, defaultValue: .distantPast)
    static private var lastRemoteMessagingRefreshDate: Date
}

// MARK: - Background Refresh

extension RemoteMessagingClient {

    struct Constants {
        static let backgroundRefreshTaskIdentifier = "com.duckduckgo.app.remoteMessageRefresh"
        static let minimumConfigurationRefreshInterval: TimeInterval = 60 * 60 * 4
    }

    static private var shouldRefresh: Bool {
        return Date().timeIntervalSince(Self.lastRemoteMessagingRefreshDate) > Constants.minimumConfigurationRefreshInterval
    }

    func registerBackgroundRefreshTaskHandler(with store: RemoteMessagingStoring) {
        let bookmarksDatabase = self.bookmarksDatabase
        let appSettings = self.appSettings
        let internalUserDecider = self.internalUserDecider

        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.backgroundRefreshTaskIdentifier, using: nil) { task in
            guard Self.shouldRefresh else {
                task.setTaskCompleted(success: true)
                Self.scheduleBackgroundRefreshTask()
                return
            }
            let client = RemoteMessagingClient(
                bookmarksDatabase: bookmarksDatabase,
                appSettings: appSettings,
                internalUserDecider: internalUserDecider
            )
            Self.backgroundRefreshTaskHandler(bgTask: task, client: client, store: store)
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

    static func backgroundRefreshTaskHandler(bgTask: BGTask, client: RemoteMessagingClient, store: RemoteMessagingStoring) {
        let fetchAndProcessTask = Task {
            do {
                try await client.fetchAndProcess(remoteMessagingStore: store)
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
}
