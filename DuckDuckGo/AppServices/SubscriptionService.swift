//
//  SubscriptionService.swift
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

import Subscription
import Combine
import BrowserServicesKit
import WebKit
import Core

final class SubscriptionService {

    let subscriptionCookieManager: SubscriptionCookieManaging
    let subscriptionFeatureAvailability: DefaultSubscriptionFeatureAvailability
    private let subscriptionManager: SubscriptionManager = AppDependencyProvider.shared.subscriptionManager
    private let privacyConfigurationManager: PrivacyConfigurationManaging
    private var cancellables: Set<AnyCancellable> = []

    var onPrivacyConfigurationUpdate: (() -> Void)?

    init(application: UIApplication = UIApplication.shared,
         privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager) {
        subscriptionCookieManager = Self.makeSubscriptionCookieManager(application: application,
                                                                       subscriptionManager: subscriptionManager,
                                                                       privacyConfigurationManager: privacyConfigurationManager)
        subscriptionFeatureAvailability = DefaultSubscriptionFeatureAvailability(privacyConfigurationManager: privacyConfigurationManager,
                                                                                 purchasePlatform: .appStore)
        self.privacyConfigurationManager = privacyConfigurationManager
        privacyConfigurationManager.updatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.onPrivacyConfigurationUpdate?()
            }
            .store(in: &cancellables)
    }

    func onLaunching() {
        subscriptionManager.loadInitialData()
    }

    private static func makeSubscriptionCookieManager(application: UIApplication,
                                                      subscriptionManager: SubscriptionManager,
                                                      privacyConfigurationManager: PrivacyConfigurationManaging) -> SubscriptionCookieManaging {
        let subscriptionCookieManager = SubscriptionCookieManager(subscriptionManager: subscriptionManager,
                                                                  currentCookieStore: {
            guard let mainViewController = application.window?.rootViewController as? MainViewController,
                mainViewController.tabManager.model.hasActiveTabs else {
                // We shouldn't interact with WebKit's cookie store unless we have a WebView,
                // eventually the subscription cookie will be refreshed on opening the first tab
                return nil
            }
            return WKHTTPCookieStoreWrapper(store: WKWebsiteDataStore.current().httpCookieStore)
        }, eventMapping: SubscriptionCookieManageEventPixelMapping())

        // Enable subscriptionCookieManager if feature flag is present
        if privacyConfigurationManager.privacyConfig.isSubfeatureEnabled(PrivacyProSubfeature.setAccessTokenCookieForSubscriptionDomains) {
            subscriptionCookieManager.enableSettingSubscriptionCookie()
        }

        return subscriptionCookieManager
    }

    func onInitialForeground() {
        handlePrivacyConfigurationUpdates()
    }

    private func handlePrivacyConfigurationUpdates() {
        onPrivacyConfigurationUpdate = { [weak self] in
            guard let self else { return }
            let isEnabled = self.privacyConfigurationManager.privacyConfig.isSubfeatureEnabled(PrivacyProSubfeature.setAccessTokenCookieForSubscriptionDomains)

            Task { @MainActor in
                if isEnabled {
                    self.subscriptionCookieManager.enableSettingSubscriptionCookie()
                } else {
                    await self.subscriptionCookieManager.disableSettingSubscriptionCookie()
                }
            }
        }
    }

    func onForeground() {
        subscriptionManager.refreshCachedSubscriptionAndEntitlements { isSubscriptionActive in
            if isSubscriptionActive {
                DailyPixel.fire(pixel: .privacyProSubscriptionActive)
            }
        }
        Task {
            await subscriptionCookieManager.refreshSubscriptionCookie()
        }
    }

}
