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
import RemoteMessaging
import PageRefreshMonitor
import PixelKit
import PixelExperimentKit

protocol DependencyProvider {

    var appSettings: AppSettings { get }
    var variantManager: VariantManager { get }
    var internalUserDecider: InternalUserDecider { get }
    var featureFlagger: FeatureFlagger { get }
    var storageCache: StorageCache { get }
    var downloadManager: DownloadManager { get }
    var autofillLoginSession: AutofillLoginSession { get }
    var autofillNeverPromptWebsitesManager: AutofillNeverPromptWebsitesManager { get }
    var configurationManager: ConfigurationManager { get }
    var configurationStore: ConfigurationStore { get }
    var pageRefreshMonitor: PageRefreshMonitor { get }
    var subscriptionManager: SubscriptionManager { get }
    var accountManager: AccountManager { get }
    var vpnFeatureVisibility: DefaultNetworkProtectionVisibility { get }
    var networkProtectionKeychainTokenStore: NetworkProtectionKeychainTokenStore { get }
    var networkProtectionTunnelController: NetworkProtectionTunnelController { get }
    var connectionObserver: ConnectionStatusObserver { get }
    var serverInfoObserver: ConnectionServerInfoObserver { get }
    var vpnSettings: VPNSettings { get }
    var persistentPixel: PersistentPixelFiring { get }

}

/// Provides dependencies for objects that are not directly instantiated
/// through `init` call (e.g. ViewControllers created from Storyboards).
final class AppDependencyProvider: DependencyProvider {

    static var shared: DependencyProvider = AppDependencyProvider()
    let appSettings: AppSettings = AppUserDefaults()
    let variantManager: VariantManager = DefaultVariantManager()
    let internalUserDecider: InternalUserDecider = ContentBlocking.shared.privacyConfigurationManager.internalUserDecider
    let featureFlagger: FeatureFlagger

    let storageCache = StorageCache()
    let downloadManager = DownloadManager()
    let autofillLoginSession = AutofillLoginSession()
    lazy var autofillNeverPromptWebsitesManager = AutofillNeverPromptWebsitesManager()

    let configurationManager: ConfigurationManager
    let configurationStore = ConfigurationStore()

    let pageRefreshMonitor = PageRefreshMonitor(onDidDetectRefreshPattern: PageRefreshMonitor.onDidDetectRefreshPattern)

    // Subscription
    let subscriptionManager: SubscriptionManager
    var accountManager: AccountManager {
        subscriptionManager.accountManager
    }
    let vpnFeatureVisibility: DefaultNetworkProtectionVisibility
    let networkProtectionKeychainTokenStore: NetworkProtectionKeychainTokenStore
    let networkProtectionTunnelController: NetworkProtectionTunnelController

    let subscriptionAppGroup = Bundle.main.appGroup(bundle: .subs)

    let connectionObserver: ConnectionStatusObserver = ConnectionStatusObserverThroughSession()
    let serverInfoObserver: ConnectionServerInfoObserver = ConnectionServerInfoObserverThroughSession()
    let vpnSettings = VPNSettings(defaults: .networkProtectionGroupDefaults)
    let persistentPixel: PersistentPixelFiring = PersistentPixel()

    private init() {
        let featureFlaggerOverrides = FeatureFlagLocalOverrides(keyValueStore: UserDefaults(suiteName: FeatureFlag.localOverrideStoreName)!,
                                                                actionHandler: FeatureFlagOverridesPublishingHandler<FeatureFlag>()
        )
        let experimentManager = ExperimentCohortsManager(store: ExperimentsDataStore(), fireCohortAssigned: PixelKit.fireExperimentEnrollmentPixel(subfeatureID:experiment:))
        featureFlagger = DefaultFeatureFlagger(internalUserDecider: internalUserDecider,
                                               privacyConfigManager: ContentBlocking.shared.privacyConfigurationManager,
                                               localOverrides: featureFlaggerOverrides,
                                               experimentManager: experimentManager,
                                               for: FeatureFlag.self)

        configurationManager = ConfigurationManager(store: configurationStore)

        // MARK: - Configure Subscription
        let subscriptionUserDefaults = UserDefaults(suiteName: subscriptionAppGroup)!
        let subscriptionEnvironment = DefaultSubscriptionManager.getSavedOrDefaultEnvironment(userDefaults: subscriptionUserDefaults)
        vpnSettings.alignTo(subscriptionEnvironment: subscriptionEnvironment)

        let entitlementsCache = UserDefaultsCache<[Entitlement]>(userDefaults: subscriptionUserDefaults,
                                                                 key: UserDefaultsCacheKey.subscriptionEntitlements,
                                                                 settings: UserDefaultsCacheSettings(defaultExpirationInterval: .minutes(20)))
        let accessTokenStorage = SubscriptionTokenKeychainStorage(keychainType: .dataProtection(.named(subscriptionAppGroup)))
        let subscriptionService = DefaultSubscriptionEndpointService(currentServiceEnvironment: subscriptionEnvironment.serviceEnvironment)
        let authService = DefaultAuthEndpointService(currentServiceEnvironment: subscriptionEnvironment.serviceEnvironment)
        let subscriptionFeatureMappingCache = DefaultSubscriptionFeatureMappingCache(subscriptionEndpointService: subscriptionService,
                                                                                     userDefaults: subscriptionUserDefaults)

        let accountManager = DefaultAccountManager(accessTokenStorage: accessTokenStorage,
                                                   entitlementsCache: entitlementsCache,
                                                   subscriptionEndpointService: subscriptionService,
                                                   authEndpointService: authService)

        let storePurchaseManager = DefaultStorePurchaseManager(subscriptionFeatureMappingCache: subscriptionFeatureMappingCache)

        let subscriptionManager = DefaultSubscriptionManager(storePurchaseManager: storePurchaseManager,
                                                             accountManager: accountManager,
                                                             subscriptionEndpointService: subscriptionService,
                                                             authEndpointService: authService,
                                                             subscriptionFeatureMappingCache: subscriptionFeatureMappingCache,
                                                             subscriptionEnvironment: subscriptionEnvironment)
        accountManager.delegate = subscriptionManager

        self.subscriptionManager = subscriptionManager

        let accessTokenProvider: () -> String? = {
            return { accountManager.accessToken }
        }()

        networkProtectionKeychainTokenStore = NetworkProtectionKeychainTokenStore(accessTokenProvider: accessTokenProvider)

        networkProtectionTunnelController = NetworkProtectionTunnelController(accountManager: accountManager,
                                                                              tokenStore: networkProtectionKeychainTokenStore,
                                                                              featureFlagger: featureFlagger,
                                                                              persistentPixel: persistentPixel,
                                                                              settings: vpnSettings)
        vpnFeatureVisibility = DefaultNetworkProtectionVisibility(userDefaults: .networkProtectionGroupDefaults,
                                                                  accountManager: accountManager)
    }

}
