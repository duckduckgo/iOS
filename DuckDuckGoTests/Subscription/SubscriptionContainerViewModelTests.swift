//
//  SubscriptionContainerViewModelTests.swift
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

import XCTest
@testable import DuckDuckGo
@testable import Subscription
import SubscriptionTestingUtilities

final class SubscriptionContainerViewModelTests: XCTestCase {
    var sut: SubscriptionContainerViewModel!

    let subscriptionManager: SubscriptionManager = {
        let accountManager = AccountManagerMock()
        let subscriptionService = SubscriptionEndpointServiceMock()
        let authService = AuthEndpointServiceMock()
        let storePurchaseManager = StorePurchaseManagerMock()
        let subscriptionFeatureMappingCache = SubscriptionFeatureMappingCacheMock()
        return SubscriptionManagerMock(accountManager: accountManager,
                                       subscriptionEndpointService: subscriptionService,
                                       authEndpointService: authService,
                                       storePurchaseManager: storePurchaseManager,
                                       currentEnvironment: SubscriptionEnvironment(serviceEnvironment: .production,
                                                                                   purchasePlatform: .appStore),
                                       canPurchase: true,
                                       subscriptionFeatureMappingCache: subscriptionFeatureMappingCache)
    }()

    let subscriptionFeatureAvailability = SubscriptionFeatureAvailabilityMock.enabled

    func testWhenInitWithOriginThenSubscriptionFlowPurchaseURLHasOriginSet() {
        // GIVEN
        let origin = "test_origin"
        let queryParameter = URLQueryItem(name: "origin", value: "test_origin")
        let expectedURL = SubscriptionURL.purchase.subscriptionURL(environment: .production).appending(percentEncodedQueryItem: queryParameter)
        let appStoreRestoreFlow = DefaultAppStoreRestoreFlow(accountManager: subscriptionManager.accountManager,
                                                             storePurchaseManager: subscriptionManager.storePurchaseManager(),
                                                             subscriptionEndpointService: subscriptionManager.subscriptionEndpointService,
                                                             authEndpointService: subscriptionManager.authEndpointService)
        let appStorePurchaseFlow = DefaultAppStorePurchaseFlow(subscriptionEndpointService: subscriptionManager.subscriptionEndpointService,
                                                               storePurchaseManager: subscriptionManager.storePurchaseManager(),
                                                               accountManager: subscriptionManager.accountManager,
                                                               appStoreRestoreFlow: appStoreRestoreFlow,
                                                               authEndpointService: subscriptionManager.authEndpointService)
        let appStoreAccountManagementFlow = DefaultAppStoreAccountManagementFlow(authEndpointService: subscriptionManager.authEndpointService,
                                                                                 storePurchaseManager: subscriptionManager.storePurchaseManager(),
                                                                                 accountManager: subscriptionManager.accountManager)

        // WHEN
        sut = .init(subscriptionManager: subscriptionManager,
                    origin: origin,
                    userScript: .init(),
                    subFeature: .init(subscriptionManager: subscriptionManager,
                                      subscriptionFeatureAvailability: subscriptionFeatureAvailability,
                                      subscriptionAttributionOrigin: nil,
                                      appStorePurchaseFlow: appStorePurchaseFlow,
                                      appStoreRestoreFlow: appStoreRestoreFlow,
                                      appStoreAccountManagementFlow: appStoreAccountManagementFlow))

        // THEN
        XCTAssertEqual(sut.flow.purchaseURL, expectedURL)
    }

    func testWhenInitWithoutOriginThenSubscriptionFlowPurchaseURLDoesNotHaveOriginSet() {
        let appStoreRestoreFlow = DefaultAppStoreRestoreFlow(accountManager: subscriptionManager.accountManager,
                                                             storePurchaseManager: subscriptionManager.storePurchaseManager(),
                                                             subscriptionEndpointService: subscriptionManager.subscriptionEndpointService,
                                                             authEndpointService: subscriptionManager.authEndpointService)
        let appStorePurchaseFlow = DefaultAppStorePurchaseFlow(subscriptionEndpointService: subscriptionManager.subscriptionEndpointService,
                                                               storePurchaseManager: subscriptionManager.storePurchaseManager(),
                                                               accountManager: subscriptionManager.accountManager,
                                                               appStoreRestoreFlow: appStoreRestoreFlow,
                                                               authEndpointService: subscriptionManager.authEndpointService)
        let appStoreAccountManagementFlow = DefaultAppStoreAccountManagementFlow(authEndpointService: subscriptionManager.authEndpointService,
                                                                                 storePurchaseManager: subscriptionManager.storePurchaseManager(),
                                                                                 accountManager: subscriptionManager.accountManager)

        // WHEN
        sut = .init(subscriptionManager: subscriptionManager,
                    origin: nil,
                    userScript: .init(),
                    subFeature: .init(subscriptionManager: subscriptionManager,
                                      subscriptionFeatureAvailability: subscriptionFeatureAvailability,
                                      subscriptionAttributionOrigin: nil,
                                      appStorePurchaseFlow: appStorePurchaseFlow,
                                      appStoreRestoreFlow: appStoreRestoreFlow,
                                      appStoreAccountManagementFlow: appStoreAccountManagementFlow))

        // THEN
        XCTAssertEqual(sut.flow.purchaseURL, SubscriptionURL.purchase.subscriptionURL(environment: .production))
    }
}
