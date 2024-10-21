//
//  SubscriptionContainerViewFactory.swift
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

import SwiftUI
import Subscription
import Networking
import os.log
import BrowserServicesKit

enum SubscriptionContainerViewFactory {

    static func makeSubscribeFlow(origin: String?,
                                  navigationCoordinator: SubscriptionNavigationCoordinator,
                                  subscriptionManager: SubscriptionManager,
                                  subscriptionFeatureAvailability: SubscriptionFeatureAvailability,
                                  privacyProDataReporter: PrivacyProDataReporting?) -> some View {

        let authClient = AppDependencyProvider.shared.oAuthClient
        let appStoreRestoreFlow = DefaultAppStoreRestoreFlow(oAuthClient: authClient,
                                                             storePurchaseManager: subscriptionManager.storePurchaseManager(),
                                                             subscriptionEndpointService: subscriptionManager.subscriptionEndpointService)
        let appStorePurchaseFlow = DefaultAppStorePurchaseFlow(oAuthClient: authClient,
                                                               subscriptionEndpointService: subscriptionManager.subscriptionEndpointService,
                                                               storePurchaseManager: subscriptionManager.storePurchaseManager(),
                                                               appStoreRestoreFlow: appStoreRestoreFlow)

        let viewModel = SubscriptionContainerViewModel(
            subscriptionManager: subscriptionManager,
            origin: origin,
            userScript: SubscriptionPagesUserScript(),
            subFeature: SubscriptionPagesUseSubscriptionFeature(subscriptionManager: subscriptionManager,
                                                                subscriptionFeatureAvailability: subscriptionFeatureAvailability,
                                                                subscriptionAttributionOrigin: origin,
                                                                appStorePurchaseFlow: appStorePurchaseFlow,
                                                                appStoreRestoreFlow: appStoreRestoreFlow,
                                                                privacyProDataReporter: privacyProDataReporter)
        )
        return SubscriptionContainerView(currentView: .subscribe, viewModel: viewModel)
            .environmentObject(navigationCoordinator)
    }

    static func makeRestoreFlow(navigationCoordinator: SubscriptionNavigationCoordinator,
                                subscriptionManager: SubscriptionManager,
                                subscriptionFeatureAvailability: SubscriptionFeatureAvailability) -> some View {
        let authClient = AppDependencyProvider.shared.oAuthClient
        let appStoreRestoreFlow = DefaultAppStoreRestoreFlow(oAuthClient: authClient,
                                                             storePurchaseManager: subscriptionManager.storePurchaseManager(),
                                                             subscriptionEndpointService: subscriptionManager.subscriptionEndpointService)
        let appStorePurchaseFlow = DefaultAppStorePurchaseFlow(oAuthClient: authClient,
                                                               subscriptionEndpointService: subscriptionManager.subscriptionEndpointService,
                                                               storePurchaseManager: subscriptionManager.storePurchaseManager(),
                                                               appStoreRestoreFlow: appStoreRestoreFlow)
        let subscriptionPagesUseSubscriptionFeature = SubscriptionPagesUseSubscriptionFeature(subscriptionManager: subscriptionManager,
                                                                                              subscriptionFeatureAvailability: subscriptionFeatureAvailability,
                                                                                              subscriptionAttributionOrigin: nil,
                                                                                              appStorePurchaseFlow: appStorePurchaseFlow,
                                                                                              appStoreRestoreFlow: appStoreRestoreFlow)
        let viewModel = SubscriptionContainerViewModel(subscriptionManager: subscriptionManager,
                                                       origin: nil,
                                                       userScript: SubscriptionPagesUserScript(),
                                                       subFeature: subscriptionPagesUseSubscriptionFeature)
        return SubscriptionContainerView(currentView: .restore, viewModel: viewModel)
            .environmentObject(navigationCoordinator)
    }

    static func makeEmailFlow(navigationCoordinator: SubscriptionNavigationCoordinator,
                              subscriptionManager: SubscriptionManager,
                              subscriptionFeatureAvailability: SubscriptionFeatureAvailability,
                              onDisappear: @escaping () -> Void) -> some View {
        let authClient = AppDependencyProvider.shared.oAuthClient
        let appStoreRestoreFlow = DefaultAppStoreRestoreFlow(oAuthClient: authClient,
                                                             storePurchaseManager: subscriptionManager.storePurchaseManager(),
                                                             subscriptionEndpointService: subscriptionManager.subscriptionEndpointService)
        let appStorePurchaseFlow = DefaultAppStorePurchaseFlow(oAuthClient: authClient,
                                                               subscriptionEndpointService: subscriptionManager.subscriptionEndpointService,
                                                               storePurchaseManager: subscriptionManager.storePurchaseManager(),
                                                               appStoreRestoreFlow: appStoreRestoreFlow)
        let viewModel = SubscriptionContainerViewModel(
            subscriptionManager: subscriptionManager,
            origin: nil,
            userScript: SubscriptionPagesUserScript(),
            subFeature: SubscriptionPagesUseSubscriptionFeature(subscriptionManager: subscriptionManager,
                                                                subscriptionFeatureAvailability: subscriptionFeatureAvailability,
                                                                subscriptionAttributionOrigin: nil,
                                                                appStorePurchaseFlow: appStorePurchaseFlow,
                                                                appStoreRestoreFlow: appStoreRestoreFlow)
        )
        return SubscriptionContainerView(currentView: .email, viewModel: viewModel)
            .environmentObject(navigationCoordinator)
            .onDisappear(perform: { onDisappear() })
    }

}
