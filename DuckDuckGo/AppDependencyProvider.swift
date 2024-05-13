//
//  AppDependencyProvider.swift
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
import Bookmarks
import Subscription
import Common
import NetworkProtection

protocol DependencyProvider {

    var appSettings: AppSettings { get }
    var variantManager: VariantManager { get }
    var internalUserDecider: InternalUserDecider { get }
    var featureFlagger: FeatureFlagger { get }
    var remoteMessagingStore: RemoteMessagingStore { get }
    var homePageConfiguration: HomePageConfiguration { get }
    var storageCache: StorageCache { get }
    var voiceSearchHelper: VoiceSearchHelperProtocol { get }
    var downloadManager: DownloadManager { get }
    var autofillLoginSession: AutofillLoginSession { get }
    var autofillNeverPromptWebsitesManager: AutofillNeverPromptWebsitesManager { get }
    var configurationManager: ConfigurationManager { get }
    var toggleProtectionsCounter: ToggleProtectionsCounter { get }
    var userBehaviorMonitor: UserBehaviorMonitor { get }
    var subscriptionFeatureAvailability: SubscriptionFeatureAvailability { get }
    var subscriptionManager: SubscriptionManaging { get }
    var accountManager: AccountManaging { get }
    var vpnFeatureVisibility: DefaultNetworkProtectionVisibility { get }
    var networkProtectionKeychainTokenStore: NetworkProtectionKeychainTokenStore { get }
    var networkProtectionAccessController: NetworkProtectionAccessController { get }
    var networkProtectionTunnelController: NetworkProtectionTunnelController { get }
}

/// Provides dependencies for objects that are not directly instantiated
/// through `init` call (e.g. ViewControllers created from Storyboards).
class AppDependencyProvider: DependencyProvider {

    static var shared: DependencyProvider = AppDependencyProvider()
    
    let appSettings: AppSettings = AppUserDefaults()
    let variantManager: VariantManager = DefaultVariantManager()
    
    let internalUserDecider: InternalUserDecider = ContentBlocking.shared.privacyConfigurationManager.internalUserDecider
    let featureFlagger: FeatureFlagger

    let remoteMessagingStore: RemoteMessagingStore = RemoteMessagingStore()
    lazy var homePageConfiguration: HomePageConfiguration = HomePageConfiguration(variantManager: variantManager,
                                                                                  remoteMessagingStore: remoteMessagingStore)
    let storageCache = StorageCache()
    let voiceSearchHelper: VoiceSearchHelperProtocol = VoiceSearchHelper()
    let downloadManager = DownloadManager()
    let autofillLoginSession = AutofillLoginSession()
    lazy var autofillNeverPromptWebsitesManager = AutofillNeverPromptWebsitesManager()

    let configurationManager = ConfigurationManager()

    let toggleProtectionsCounter: ToggleProtectionsCounter = ContentBlocking.shared.privacyConfigurationManager.toggleProtectionsCounter
    let userBehaviorMonitor = UserBehaviorMonitor()

    let subscriptionFeatureAvailability: SubscriptionFeatureAvailability = DefaultSubscriptionFeatureAvailability(
        privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager,
        subscriptionPlatform: .appStore)

    // Subscription
    let subscriptionManager: SubscriptionManaging
    var accountManager: AccountManaging {
        subscriptionManager.accountManager
    }
    let vpnFeatureVisibility: DefaultNetworkProtectionVisibility
    let networkProtectionKeychainTokenStore: NetworkProtectionKeychainTokenStore
    let networkProtectionAccessController: NetworkProtectionAccessController
    let networkProtectionTunnelController: NetworkProtectionTunnelController

    let subscriptionAppGroup = Bundle.main.appGroup(bundle: .subs)

    // swiftlint:disable:next function_body_length
    init() {
        featureFlagger = DefaultFeatureFlagger(internalUserDecider: internalUserDecider,
                                               privacyConfigManager: ContentBlocking.shared.privacyConfigurationManager)

        // MARK: - Configure Subscription
        let subscriptionUserDefaults = UserDefaults(suiteName: subscriptionAppGroup)!
        let subscriptionEnvironment = SubscriptionManager.getSavedOrDefaultEnvironment(userDefaults: subscriptionUserDefaults)
        let entitlementsCache = UserDefaultsCache<[Entitlement]>(userDefaults: subscriptionUserDefaults,
                                                                 key: UserDefaultsCacheKey.subscriptionEntitlements,
                                                                 settings: UserDefaultsCacheSettings(defaultExpirationInterval: .minutes(20)))
        let accessTokenStorage = SubscriptionTokenKeychainStorage(keychainType: .dataProtection(.named(subscriptionAppGroup)))
        let subscriptionService = SubscriptionService(currentServiceEnvironment: subscriptionEnvironment.serviceEnvironment)
        let authService = AuthService(currentServiceEnvironment: subscriptionEnvironment.serviceEnvironment)
        let accountManager = AccountManager(accessTokenStorage: accessTokenStorage,
                                            entitlementsCache: entitlementsCache,
                                            subscriptionService: subscriptionService,
                                            authService: authService)
        if #available(iOS 15.0, *) {
            subscriptionManager = SubscriptionManager(storePurchaseManager: StorePurchaseManager(),
                                                      accountManager: accountManager,
                                                      subscriptionService: subscriptionService,
                                                      authService: authService,
                                                      subscriptionEnvironment: subscriptionEnvironment)
        } else {
            // This is used just for iOS <15, it's a sort of mocked environment that will not be used.
            subscriptionManager = SubscriptionManageriOS14(accountManager: accountManager)
        }
        let isProduction = (subscriptionEnvironment.serviceEnvironment == .production)
        VPNSettings(defaults: .networkProtectionGroupDefaults).selectedEnvironment = isProduction ? .production : .staging


        let subscriptionFeatureAvailability: SubscriptionFeatureAvailability = DefaultSubscriptionFeatureAvailability(
            privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager,
            subscriptionPlatform: .appStore)
        let accessTokenProvider: () -> String? = {
            func isSubscriptionEnabled() -> Bool {
                if let subscriptionOverrideEnabled = UserDefaults.networkProtectionGroupDefaults.subscriptionOverrideEnabled {
#if ALPHA || DEBUG
                    return subscriptionOverrideEnabled
#else
                    return false
#endif
                }
                return subscriptionFeatureAvailability.isFeatureAvailable
            }

            if isSubscriptionEnabled() {
                return { accountManager.accessToken }
            }
            return { nil }
        }()
        networkProtectionKeychainTokenStore = NetworkProtectionKeychainTokenStore(keychainType: .dataProtection(.unspecified),
                                                                                  serviceName: "\(Bundle.main.bundleIdentifier!).authToken",
                                                                                  errorEvents: .networkProtectionAppDebugEvents,
                                                                                  isSubscriptionEnabled: accountManager.isUserAuthenticated,
                                                                                  accessTokenProvider: accessTokenProvider)
        networkProtectionTunnelController = NetworkProtectionTunnelController(accountManager: accountManager,
                                                                              tokenStore: networkProtectionKeychainTokenStore)
        networkProtectionAccessController = NetworkProtectionAccessController(featureFlagger: featureFlagger,
                                                                              internalUserDecider: internalUserDecider,
                                                                              accountManager: subscriptionManager.accountManager,
                                                                              tokenStore: networkProtectionKeychainTokenStore,
                                                                              networkProtectionTunnelController: networkProtectionTunnelController)
        self.vpnFeatureVisibility = DefaultNetworkProtectionVisibility(networkProtectionAccessManager: networkProtectionAccessController,
                                                                       featureFlagger: featureFlagger,
                                                                       accountManager: accountManager)
    }

}
