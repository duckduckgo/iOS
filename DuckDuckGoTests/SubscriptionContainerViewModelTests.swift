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

@available(iOS 15.0, *)
final class SubscriptionContainerViewModelTests: XCTestCase {
    private var sut: SubscriptionContainerViewModel!

    func testWhenInitWithPurchaseURLThenSubscriptionFlowReflectsURL() {
        // GIVEN
        let queryParameter = URLQueryItem(name: "origin", value: "test_origin")
        let url = URL.subscriptionPurchase.appending(percentEncodedQueryItem: queryParameter)

        // WHEN
        sut = .init(purchaseURL: url, userScript: .init(), subFeature: .init(subscriptionAttributionOrigin: nil))

        // THEN
        XCTAssertEqual(sut.flow.purchaseURL, url)
    }

}
