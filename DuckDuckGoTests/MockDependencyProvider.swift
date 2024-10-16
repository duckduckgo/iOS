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
import RemoteMessaging
@testable import DuckDuckGo

class MockDependencyProvider: DependencyProvider {
    var appSettings: AppSettings
    var variantManager: VariantManager
    var featureFlagger: FeatureFlagger
    var internalUserDecider: InternalUserDecider
    var storageCache: StorageCache
    var downloadManager: DownloadManager
    var autofillLoginSession: AutofillLoginSession
    var autofillNeverPromptWebsitesManager: AutofillNeverPromptWebsitesManager
    var configurationManager: ConfigurationManager
    var configurationStore: ConfigurationStore
    var userBehaviorMonitor: UserBehaviorMonitor
    var subscriptionManager: SubscriptionManager
    var accountManager: AccountManager
    var vpnFeatureVisibility: DefaultNetworkProtectionVisibility
    var networkProtectionKeychainTokenStore: NetworkProtectionKeychainTokenStore
    var networkProtectionTunnelController: NetworkProtectionTunnelController
    var connectionObserver: NetworkProtection.ConnectionStatusObserver
    var serverInfoObserver: NetworkProtection.ConnectionServerInfoObserver
    var vpnSettings: NetworkProtection.VPNSettings
    var persistentPixel: PersistentPixelFiring

    init() {
        let defaultProvider = AppDependencyProvider.makeTestingInstance()
        appSettings = defaultProvider.appSettings
        variantManager = defaultProvider.variantManager
        featureFlagger = defaultProvider.featureFlagger
        internalUserDecider = defaultProvider.internalUserDecider
        storageCache = defaultProvider.storageCache
        downloadManager = defaultProvider.downloadManager
        autofillLoginSession = defaultProvider.autofillLoginSession
        autofillNeverPromptWebsitesManager = defaultProvider.autofillNeverPromptWebsitesManager
        configurationStore = defaultProvider.configurationStore
        configurationManager = defaultProvider.configurationManager
        userBehaviorMonitor = defaultProvider.userBehaviorMonitor

        accountManager = AccountManagerMock()

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

        let accessTokenProvider: () -> String? = { { "sometoken" } }()
        networkProtectionKeychainTokenStore = NetworkProtectionKeychainTokenStore(accessTokenProvider: accessTokenProvider)
        networkProtectionTunnelController = NetworkProtectionTunnelController(accountManager: accountManager,
                                                                              tokenStore: networkProtectionKeychainTokenStore,
                                                                              persistentPixel: MockPersistentPixel())
        vpnFeatureVisibility = DefaultNetworkProtectionVisibility(userDefaults: .networkProtectionGroupDefaults,
                                                                  accountManager: accountManager)

        connectionObserver = ConnectionStatusObserverThroughSession()
        serverInfoObserver = ConnectionServerInfoObserverThroughSession()
        vpnSettings = VPNSettings(defaults: .networkProtectionGroupDefaults)
        persistentPixel = MockPersistentPixel()
    }
}
