//
//  RemoteMessagingConfigMatcherProvider.swift
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

import Common
import Core
import Foundation
import BrowserServicesKit
import Persistence
import Bookmarks
import RemoteMessaging
import NetworkProtection
import Subscription

extension DefaultVPNActivationDateStore: VPNActivationDateProviding {}

final class RemoteMessagingConfigMatcherProvider: RemoteMessagingConfigMatcherProviding {

    init(
        bookmarksDatabase: CoreDataDatabase,
        appSettings: AppSettings,
        internalUserDecider: InternalUserDecider,
        duckPlayerStorage: DuckPlayerStorage
    ) {
        self.bookmarksDatabase = bookmarksDatabase
        self.appSettings = appSettings
        self.internalUserDecider = internalUserDecider
        self.duckPlayerStorage = duckPlayerStorage
    }

    let bookmarksDatabase: CoreDataDatabase
    let appSettings: AppSettings
    let duckPlayerStorage: DuckPlayerStorage
    let internalUserDecider: InternalUserDecider

    func refreshConfigMatcher(using store: RemoteMessagingStoring) async -> RemoteMessagingConfigMatcher {

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

        var isDuckPlayerOnboarded: Bool {
            duckPlayerStorage.userInteractedWithDuckPlayer
        }
        var isDuckPlayerEnabled: Bool {
            appSettings.duckPlayerMode != .disabled
        }
        
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
                    isPrivacyProSubscriptionExpiring = true
                case .expired, .inactive:
                    isPrivacyProSubscriptionExpired = true
                case .unknown:
                    break // Not supported in RMF
                }

                surveyActionMapper = DefaultRemoteMessagingSurveyURLBuilder(
                    statisticsStore: statisticsStore,
                    vpnActivationDateStore: DefaultVPNActivationDateStore(),
                    subscription: subscription)
            } else {
                surveyActionMapper = DefaultRemoteMessagingSurveyURLBuilder(
                    statisticsStore: statisticsStore,
                    vpnActivationDateStore: DefaultVPNActivationDateStore(),
                    subscription: nil)
            }
        } else {
            surveyActionMapper = DefaultRemoteMessagingSurveyURLBuilder(
                statisticsStore: statisticsStore,
                vpnActivationDateStore: DefaultVPNActivationDateStore(),
                subscription: nil)
        }

        let dismissedMessageIds = store.fetchDismissedRemoteMessageIDs()
        let shownMessageIds = store.fetchShownRemoteMessageIDs()

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
                                                       isDuckPlayerOnboarded: isDuckPlayerOnboarded,
                                                       isDuckPlayerEnabled: isDuckPlayerEnabled,
                                                       dismissedMessageIds: dismissedMessageIds,
                                                       shownMessageIds: shownMessageIds),
            percentileStore: RemoteMessagingPercentileUserDefaultsStore(keyValueStore: UserDefaults.standard),
            surveyActionMapper: surveyActionMapper,
            dismissedMessageIds: dismissedMessageIds
        )
    }
}
