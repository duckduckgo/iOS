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
    var downloadManager: DownloadManager { get }
    var autofillLoginSession: AutofillLoginSession { get }
    var autofillNeverPromptWebsitesManager: AutofillNeverPromptWebsitesManager { get }
    var configurationManager: ConfigurationManager { get }
    var configurationStore: ConfigurationStore { get }
    var userBehaviorMonitor: UserBehaviorMonitor { get }
    var subscriptionManager: any SubscriptionManager { get }
    var privacyProInfoProvider: any PrivacyProInfoProvider { get }
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

    let userBehaviorMonitor = UserBehaviorMonitor()

    // Subscription
    let subscriptionManager: SubscriptionManager
    let privacyProInfoProvider: any PrivacyProInfoProvider
    let vpnFeatureVisibility: DefaultNetworkProtectionVisibility
    let networkProtectionKeychainTokenStore: NetworkProtectionKeychainTokenStore
    let networkProtectionTunnelController: NetworkProtectionTunnelController

    let subscriptionAppGroup = Bundle.main.appGroup(bundle: .subs)

    let connectionObserver: ConnectionStatusObserver = ConnectionStatusObserverThroughSession()
    let serverInfoObserver: ConnectionServerInfoObserver = ConnectionServerInfoObserverThroughSession()
    let vpnSettings = VPNSettings(defaults: .networkProtectionGroupDefaults)
    let persistentPixel: PersistentPixelFiring = PersistentPixel()

    private init() {
        featureFlagger = DefaultFeatureFlagger(internalUserDecider: internalUserDecider,
                                               privacyConfigManager: ContentBlocking.shared.privacyConfigurationManager)

        configurationManager = ConfigurationManager(store: configurationStore)

        // MARK: - Configure Subscription
        let subscriptionUserDefaults = UserDefaults(suiteName: subscriptionAppGroup)!
        let subscriptionEnvironment = DefaultSubscriptionManager.getSavedOrDefaultEnvironment(userDefaults: subscriptionUserDefaults)
        vpnSettings.alignTo(subscriptionEnvironment: subscriptionEnvironment)

        let configuration = URLSessionConfiguration.default
        configuration.httpCookieStorage = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let urlSession = URLSession(configuration: configuration,
                                    delegate: SessionDelegate(),
                                    delegateQueue: nil)
        let apiService = DefaultAPIService(urlSession: urlSession)
        let authEnvironment: OAuthEnvironment = subscriptionEnvironment.serviceEnvironment == .production ? .production : .staging

        let authService = DefaultOAuthService(baseURL: authEnvironment.url, apiService: apiService)

        // keychain storage
        let subscriptionAppGroup = Bundle.main.appGroup(bundle: .subs)
        let tokenStorage = SubscriptionTokenKeychainStorageV2(keychainType: .dataProtection(.named(subscriptionAppGroup)))
        let legacyAccountStorage = SubscriptionTokenKeychainStorage(keychainType: .dataProtection(.named(subscriptionAppGroup)))

        let authClient = DefaultOAuthClient(tokensStorage: tokenStorage,
                                            legacyTokenStorage: legacyAccountStorage,
                                            authService: authService)

        self.privacyProInfoProvider = authClient

        apiService.authorizationRefresherCallback = { _ in
            guard let tokenContainer = tokenStorage.tokenContainer else {
                throw OAuthClientError.internalError("Missing refresh token")
            }

            if tokenContainer.decodedAccessToken.isExpired() {
                Logger.OAuth.debug("Refreshing tokens")
                let tokens = try await authClient.getTokens(policy: .localForceRefresh)
                return tokens.accessToken
            } else {
                Logger.general.debug("Trying to refresh valid token, using the old one")
                return tokenContainer.accessToken
            }
        }
        let storePurchaseManager = DefaultStorePurchaseManager()
        
        let subscriptionEndpointService = DefaultSubscriptionEndpointService(apiService: apiService,
                                                                             baseURL: subscriptionEnvironment.serviceEnvironment.url)
        let pixelHandler: SubscriptionManager.PixelHandler = { type in
            switch type {
            case .deadToken:
                Pixel.fire(pixel: .privacyProDeadTokenDetected)
            }
        }
        let subscriptionManager = DefaultSubscriptionManager(storePurchaseManager: storePurchaseManager,
                                                             oAuthClient: authClient,
                                                             subscriptionEndpointService: subscriptionEndpointService,
                                                             subscriptionEnvironment: subscriptionEnvironment,
                                                             pixelHandler: pixelHandler)
        self.subscriptionManager = subscriptionManager
        networkProtectionKeychainTokenStore = NetworkProtectionKeychainTokenStore(accessTokenProvider: {
            guard let token = subscriptionManager.getTokenContainerSynchronously(policy: .localValid)?.accessToken else {
                Logger.networkProtection.error("NetworkProtectionKeychainTokenStore failed to provide token")
                return nil
            }
            return token
        })
        networkProtectionTunnelController = NetworkProtectionTunnelController(tokenStore: networkProtectionKeychainTokenStore,
                                                                              persistentPixel: persistentPixel)
        vpnFeatureVisibility = DefaultNetworkProtectionVisibility(userDefaults: .networkProtectionGroupDefaults,
                                                                  oAuthClient: authClient)
    }
}

extension DefaultOAuthClient: PrivacyProInfoProvider {
    
    var hasVPNEntitlements: Bool {
        guard let tokenContainer = tokenStorage.tokenContainer else {
            return false
        }
        return tokenContainer.decodedAccessToken.hasEntitlement(.networkProtection)
    }
}
