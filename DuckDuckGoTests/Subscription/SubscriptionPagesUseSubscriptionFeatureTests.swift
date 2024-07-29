//
//  SubscriptionPagesUseSubscriptionFeatureTests.swift
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

final class SubscriptionPagesUseSubscriptionFeatureTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let appStorePurchaseFlow = AppStorePurchaseFlowMock(purchaseSubscriptionResult: .success("TransactionJWS"),
                                                            completeSubscriptionPurchaseResult: .success(PurchaseUpdate(type: "t", token: "t")))
        let appStoreAccountManagementFlow = AppStoreAccountManagementFlowMock(refreshAuthTokenIfNeededResult: .success("Something"))
        let feature = SubscriptionPagesUseSubscriptionFeature(subscriptionManager: SubscriptionMockFactory.subscriptionManager,
                                                             subscriptionAttributionOrigin: "???",
                                                             appStorePurchaseFlow: appStorePurchaseFlow,
                                                             appStoreRestoreFlow: SubscriptionMockFactory.appStoreRestoreFlow,
                                                             appStoreAccountManagementFlow: appStoreAccountManagementFlow)
        // To be implemented
    }
}
