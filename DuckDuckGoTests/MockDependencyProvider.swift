//
//  MockDependencyProvider.swift
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
import Core
import BrowserServicesKit
import DDGSync
import Subscription
import SubscriptionTestingUtilities
import NetworkProtection
@testable import DuckDuckGo

class MockDependencyProvider: DependencyProvider {
    var appSettings: AppSettings
    var variantManager: VariantManager
    var featureFlagger: FeatureFlagger
    var internalUserDecider: InternalUserDecider
    var remoteMessagingStore: RemoteMessagingStore
    var homePageConfiguration: HomePageConfiguration
    var storageCache: StorageCache
    var voiceSearchHelper: VoiceSearchHelperProtocol
    var downloadManager: DownloadManager
    var autofillLoginSession: AutofillLoginSession
    var autofillNeverPromptWebsitesManager: AutofillNeverPromptWebsitesManager
    var configurationManager: ConfigurationManager
    var userBehaviorMonitor: UserBehaviorMonitor
    var toggleProtectionsCounter: ToggleProtectionsCounter
    var subscriptionFeatureAvailability: SubscriptionFeatureAvailability
    var subscriptionManager: SubscriptionManager
    var accountManager: AccountManager
    var vpnFeatureVisibility: DefaultNetworkProtectionVisibility
    var networkProtectionKeychainTokenStore: NetworkProtectionKeychainTokenStore
    var networkProtectionTunnelController: NetworkProtectionTunnelController
    var connectionObserver: NetworkProtection.ConnectionStatusObserver
    var vpnSettings: NetworkProtection.VPNSettings

    init() {
        let defaultProvider = AppDependencyProvider()
        appSettings = defaultProvider.appSettings
        variantManager = defaultProvider.variantManager
        featureFlagger = defaultProvider.featureFlagger
        internalUserDecider = defaultProvider.internalUserDecider
        remoteMessagingStore = defaultProvider.remoteMessagingStore
        homePageConfiguration = defaultProvider.homePageConfiguration
        storageCache = defaultProvider.storageCache
        voiceSearchHelper = defaultProvider.voiceSearchHelper
        downloadManager = defaultProvider.downloadManager
        autofillLoginSession = defaultProvider.autofillLoginSession
        autofillNeverPromptWebsitesManager = defaultProvider.autofillNeverPromptWebsitesManager
        configurationManager = defaultProvider.configurationManager
        userBehaviorMonitor = defaultProvider.userBehaviorMonitor
        toggleProtectionsCounter = defaultProvider.toggleProtectionsCounter
        subscriptionFeatureAvailability = defaultProvider.subscriptionFeatureAvailability

        accountManager = AccountManagerMock()
        if #available(iOS 15.0, *) {
            let subscriptionService = DefaultSubscriptionEndpointService(currentServiceEnvironment: .production)
            let authService = DefaultAuthEndpointService(currentServiceEnvironment: .production)
            let storePurchaseManager = DefaultStorePurchaseManager()
            subscriptionManager = SubscriptionManagerMock(accountManager: accountManager,
                                                          subscriptionEndpointService: subscriptionService,
                                                          authEndpointService: authService,
                                                          storePurchaseManager: storePurchaseManager,
                                                          currentEnvironment: SubscriptionEnvironment(serviceEnvironment: .production,
                                                                                                      purchasePlatform: .appStore),
                                                          canPurchase: true)
        } else {
            // This is used just for iOS <15, it's a sort of mocked environment that will not be used.
            subscriptionManager = SubscriptionManageriOS14(accountManager: accountManager)
        }

        let accessTokenProvider: () -> String? = { { "sometoken" } }()
        networkProtectionKeychainTokenStore = NetworkProtectionKeychainTokenStore(accessTokenProvider: accessTokenProvider)
        networkProtectionTunnelController = NetworkProtectionTunnelController(accountManager: accountManager,
                                                                              tokenStore: networkProtectionKeychainTokenStore)
        vpnFeatureVisibility = DefaultNetworkProtectionVisibility(userDefaults: .networkProtectionGroupDefaults,
                                                                  accountManager: accountManager)

        connectionObserver = ConnectionStatusObserverThroughSession()
        vpnSettings = VPNSettings(defaults: .networkProtectionGroupDefaults)
    }
}
