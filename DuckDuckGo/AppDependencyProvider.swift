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
import Networking
import os.log

protocol DependencyProvider {

    var appSettings: AppSettings { get }
    var variantManager: VariantManager { get }
    var internalUserDecider: InternalUserDecider { get }
    var featureFlagger: FeatureFlagger { get }
    var storageCache: StorageCache { get }
    var voiceSearchHelper: VoiceSearchHelperProtocol { get }
    var downloadManager: DownloadManager { get }
    var autofillLoginSession: AutofillLoginSession { get }
    var autofillNeverPromptWebsitesManager: AutofillNeverPromptWebsitesManager { get }
    var configurationManager: ConfigurationManager { get }
    var configurationStore: ConfigurationStore { get }
    var userBehaviorMonitor: UserBehaviorMonitor { get }
    var subscriptionFeatureAvailability: SubscriptionFeatureAvailability { get }
    var subscriptionManager: SubscriptionManager { get }
    var privacyProInfoProvider: any PrivacyProInfoProvider { get }
    var vpnFeatureVisibility: DefaultNetworkProtectionVisibility { get }
    var networkProtectionKeychainTokenStore: NetworkProtectionKeychainTokenStore { get }
    var networkProtectionTunnelController: NetworkProtectionTunnelController { get }
    var connectionObserver: ConnectionStatusObserver { get }
    var serverInfoObserver: ConnectionServerInfoObserver { get }
    var vpnSettings: VPNSettings { get }
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
    let voiceSearchHelper: VoiceSearchHelperProtocol = VoiceSearchHelper()
    let downloadManager = DownloadManager()
    let autofillLoginSession = AutofillLoginSession()
    lazy var autofillNeverPromptWebsitesManager = AutofillNeverPromptWebsitesManager()

    let configurationManager: ConfigurationManager
    let configurationStore = ConfigurationStore()

    let userBehaviorMonitor = UserBehaviorMonitor()

    let subscriptionFeatureAvailability: SubscriptionFeatureAvailability = DefaultSubscriptionFeatureAvailability(
        privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager,
        purchasePlatform: .appStore)

    // Subscription
    let subscriptionManager: SubscriptionManager
//    var accountManager: AccountManager {
//        subscriptionManager.accountManager
//    }
    let privacyProInfoProvider: any PrivacyProInfoProvider
    let vpnFeatureVisibility: DefaultNetworkProtectionVisibility
    let networkProtectionKeychainTokenStore: NetworkProtectionKeychainTokenStore
    let networkProtectionTunnelController: NetworkProtectionTunnelController

    let subscriptionAppGroup = Bundle.main.appGroup(bundle: .subs)

    let connectionObserver: ConnectionStatusObserver = ConnectionStatusObserverThroughSession()
    let serverInfoObserver: ConnectionServerInfoObserver = ConnectionServerInfoObserverThroughSession()
    let vpnSettings = VPNSettings(defaults: .networkProtectionGroupDefaults)

    private init() {
        featureFlagger = DefaultFeatureFlagger(internalUserDecider: internalUserDecider,
                                               privacyConfigManager: ContentBlocking.shared.privacyConfigurationManager)

        configurationManager = ConfigurationManager(store: configurationStore)

        // MARK: - Configure Subscription
        let subscriptionUserDefaults = UserDefaults(suiteName: subscriptionAppGroup)!
        let subscriptionEnvironment = DefaultSubscriptionManager.getSavedOrDefaultEnvironment(userDefaults: subscriptionUserDefaults)
        vpnSettings.alignTo(subscriptionEnvironment: subscriptionEnvironment)

//        let entitlementsCache = UserDefaultsCache<[Entitlement]>(userDefaults: subscriptionUserDefaults,
//                                                                 key: UserDefaultsCacheKey.subscriptionEntitlements,
//                                                                 settings: UserDefaultsCacheSettings(defaultExpirationInterval: .minutes(20)))
//        let accessTokenStorage = SubscriptionTokenKeychainStorage(keychainType: .dataProtection(.named(subscriptionAppGroup)))
//        let subscriptionService = DefaultSubscriptionEndpointService(currentServiceEnvironment: subscriptionEnvironment.serviceEnvironment)
//        let authService = DefaultAuthEndpointService(currentServiceEnvironment: subscriptionEnvironment.serviceEnvironment)
//        let accountManager = DefaultAccountManager(accessTokenStorage: accessTokenStorage,
//                                                   entitlementsCache: entitlementsCache,
//                                                   subscriptionEndpointService: subscriptionService,
//                                                   authEndpointService: authService)

        let configuration = URLSessionConfiguration.default
        configuration.httpCookieStorage = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let urlSession = URLSession(configuration: configuration,
                                    delegate: SessionDelegate(),
                                    delegateQueue: nil)
        let apiService = DefaultAPIService(urlSession: urlSession)
        let authEnvironment: OAuthEnvironment = subscriptionEnvironment.serviceEnvironment == .production ? .production : .staging

        let authService = DefaultOAuthService(baseURL: authEnvironment.url, apiService: apiService)
        let keychainManager = SubscriptionKeychainManager()
        let authClient = DefaultOAuthClient(tokensStorage: keychainManager, authService: authService)
        self.privacyProInfoProvider = authClient
        apiService.authorizationRefresherCallback = { _ in // TODO: is this updated?
            // safety check
            if keychainManager.tokensContainer?.decodedAccessToken.isExpired() == false {
                assertionFailure("Refresh attempted on non expired token")
            }
            Logger.OAuth.debug("Refreshing tokens")
            let tokens = try await authClient.refreshTokens()
            return tokens.accessToken
        }
        let storePurchaseManager = DefaultStorePurchaseManager()
        
        let subscriptionEndpointService = DefaultSubscriptionEndpointService(apiService: apiService, baseURL: authEnvironment.url)
        let subscriptionManager = DefaultSubscriptionManager(storePurchaseManager: storePurchaseManager,
                                                             oAuthClient: authClient,
                                                             subscriptionEndpointService: subscriptionEndpointService,
                                                             subscriptionEnvironment: subscriptionEnvironment)
        self.subscriptionManager = subscriptionManager

        let subscriptionFeatureAvailability: SubscriptionFeatureAvailability = DefaultSubscriptionFeatureAvailability(
            privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager,
            purchasePlatform: .appStore)
        let accessTokenProvider: () -> String? = { // TODO: refactor all of this
            return {
//                try? await authClient.getTokens(policy: .local).accessToken
                return ""
            }
        }()
#if os(macOS)
        networkProtectionKeychainTokenStore = NetworkProtectionKeychainTokenStore(keychainType: .dataProtection(.unspecified),
                                                                                  serviceName: "\(Bundle.main.bundleIdentifier!).authToken",
                                                                                  errorEvents: .networkProtectionAppDebugEvents,
                                                                                  accessTokenProvider: accessTokenProvider)
#else
        networkProtectionKeychainTokenStore = NetworkProtectionKeychainTokenStore(accessTokenProvider: accessTokenProvider)
#endif
        networkProtectionTunnelController = NetworkProtectionTunnelController(tokenStore: networkProtectionKeychainTokenStore)
        vpnFeatureVisibility = DefaultNetworkProtectionVisibility(userDefaults: .networkProtectionGroupDefaults,
                                                                  oAuthClient: authClient)
    }

    /// Only meant to be used for testing.
    ///
    static func makeTestingInstance() -> Self {
        Self.init()
    }
}

extension DefaultOAuthClient: PrivacyProInfoProvider {
    
    var hasVPNEntitlements: Bool {
        guard let tokensContainer = tokensStorage.tokensContainer else {
            return false
        }
        return tokensContainer.decodedAccessToken.hasEntitlement(.networkProtection)
    }
}
