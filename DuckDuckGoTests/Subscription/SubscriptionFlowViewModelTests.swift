//
//  SubscriptionFlowViewModelTests.swift
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

final class SubscriptionFlowViewModelTests: XCTestCase {
    private var sut: SubscriptionFlowViewModel!
    
    let subscriptionManager = SubscriptionManagerMock()
//        let accountManager = AccountManagerMock()
//        let subscriptionService = DefaultSubscriptionEndpointService(currentServiceEnvironment: .production)
//        let authService = DefaultAuthEndpointService(currentServiceEnvironment: .production)
//        let storePurchaseManager = DefaultStorePurchaseManager()
//        return SubscriptionManagerMock(accountManager: accountManager,
//                                       subscriptionEndpointService: subscriptionService,
//                                       authEndpointService: authService,
//                                       storePurchaseManager: storePurchaseManager,
//                                       currentEnvironment: SubscriptionEnvironment(serviceEnvironment: .production,
//                                                                                   purchasePlatform: .appStore),
//                                       canPurchase: true)
//    }()

    let subscriptionFeatureAvailability = SubscriptionFeatureAvailabilityMock.enabled

    func testWhenInitWithOriginThenSubscriptionFlowPurchaseURLHasOriginSet() {
        // GIVEN
        let origin = "test_origin"
        let queryParameter = URLQueryItem(name: "origin", value: "test_origin")
        let expectedURL = SubscriptionURL.purchase.subscriptionURL(environment: .production).appending(percentEncodedQueryItem: queryParameter)
        let storePurchaseManager = DefaultStorePurchaseManager()
        let appStoreRestoreFlow = DefaultAppStoreRestoreFlow(subscriptionManager: subscriptionManager,
                                                             storePurchaseManager: storePurchaseManager)
        let appStorePurchaseFlow = DefaultAppStorePurchaseFlow(subscriptionManager: subscriptionManager,
                                                               storePurchaseManager: storePurchaseManager,
                                                               appStoreRestoreFlow: appStoreRestoreFlow)
        subscriptionManager.resultURL = SubscriptionURL.purchase.subscriptionURL(environment: .production)
        // WHEN
        sut = .init(origin: origin, userScript: .init(), subFeature: .init(subscriptionManager: subscriptionManager,
                                                                           subscriptionFeatureAvailability: subscriptionFeatureAvailability,
                                                                           subscriptionAttributionOrigin: nil,
                                                                           appStorePurchaseFlow: appStorePurchaseFlow,
                                                                           appStoreRestoreFlow: appStoreRestoreFlow),
                    subscriptionManager: subscriptionManager)
        
        // THEN
        XCTAssertEqual(sut.purchaseURL, expectedURL)
    }
    
    func testWhenInitWithoutOriginThenSubscriptionFlowPurchaseURLDoesNotHaveOriginSet() {
        let storePurchaseManager = DefaultStorePurchaseManager()
        let appStoreRestoreFlow = DefaultAppStoreRestoreFlow(subscriptionManager: subscriptionManager,
                                                             storePurchaseManager: storePurchaseManager)
        let appStorePurchaseFlow = DefaultAppStorePurchaseFlow(subscriptionManager: subscriptionManager,
                                                               storePurchaseManager: storePurchaseManager,
                                                               appStoreRestoreFlow: appStoreRestoreFlow)
        subscriptionManager.resultURL = SubscriptionURL.purchase.subscriptionURL(environment: .production)
        // WHEN
        sut = .init(origin: nil, userScript: .init(), subFeature: .init(subscriptionManager: subscriptionManager,
                                                                        subscriptionFeatureAvailability: subscriptionFeatureAvailability,
                                                                        subscriptionAttributionOrigin: nil,
                                                                        appStorePurchaseFlow: appStorePurchaseFlow,
                                                                        appStoreRestoreFlow: appStoreRestoreFlow),
                    subscriptionManager: subscriptionManager)
        
        // THEN
        XCTAssertEqual(sut.purchaseURL, SubscriptionURL.purchase.subscriptionURL(environment: .production))
    }
    
}
