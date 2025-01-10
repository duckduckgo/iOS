//
//  TabURLInterceptorTests.swift
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
import Subscription
import SubscriptionTestingUtilities
@testable import DuckDuckGo

class TabURLInterceptorDefaultTests: XCTestCase {
    
    var urlInterceptor: TabURLInterceptorDefault!
    
    override func setUp() {
        super.setUp()
        urlInterceptor = TabURLInterceptorDefault(featureFlagger: MockFeatureFlagger(), canPurchase: { true })
    }
    
    override func tearDown() {
        urlInterceptor = nil
        super.tearDown()
    }
    
    func testAllowsNavigationForNonDuckDuckGoDomain() {
        let url = URL(string: "https://www.example.com")!
        XCTAssertTrue(urlInterceptor.allowsNavigatingTo(url: url))
    }
    
    func testAllowsNavigationForUninterceptedDuckDuckGoPath() {
        let url = URL(string: "https://duckduckgo.com/about")!
        XCTAssertTrue(urlInterceptor.allowsNavigatingTo(url: url))
    }
    
    func testNotificationForInterceptedPrivacyProPath() {
        _ = self.expectation(forNotification: .urlInterceptPrivacyPro, object: nil, handler: nil)
        
        let url = URL(string: "https://duckduckgo.com/pro")!
        let canNavigate = urlInterceptor.allowsNavigatingTo(url: url)
        
        // Fail if no note is posted
        XCTAssertFalse(canNavigate)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("Notification expectation failed: \(error)")
            }
        }
    }

    func testWhenURLIsPrivacyProAndHasOriginQueryParameterThenNotificationUserInfoHasOriginSet() throws {
        // GIVEN
        var capturedNotification: Notification?
        _ = self.expectation(forNotification: .urlInterceptPrivacyPro, object: nil, handler: { notification in
            capturedNotification = notification
            return true
        })
        let url = try XCTUnwrap(URL(string: "https://duckduckgo.com/pro?origin=test_origin"))
        
        // WHEN
        _ = urlInterceptor.allowsNavigatingTo(url: url)

        // THEN
        waitForExpectations(timeout: 1)
        let origin = try XCTUnwrap(capturedNotification?.userInfo?[AttributionParameter.origin] as? String)
        XCTAssertEqual(origin, "test_origin")
    }

    func testWhenURLIsPrivacyProAndDoesNotHaveOriginQueryParameterThenNotificationUserInfoDoesNotHaveOriginSet() throws {
        // GIVEN
        var capturedNotification: Notification?
        _ = self.expectation(forNotification: .urlInterceptPrivacyPro, object: nil, handler: { notification in
            capturedNotification = notification
            return true
        })
        let url = try XCTUnwrap(URL(string: "https://duckduckgo.com/pro"))

        // WHEN
        _ = urlInterceptor.allowsNavigatingTo(url: url)

        // THEN
        waitForExpectations(timeout: 1)
        XCTAssertNil(capturedNotification?.userInfo?[AttributionParameter.origin] as? String)
    }

    func testAllowsNavigationForNonAIChatURL() {
        let url = URL(string: "https://www.example.com")!
        XCTAssertTrue(urlInterceptor.allowsNavigatingTo(url: url))
    }

    func testNotificationForInterceptedAIChatPathWhenFeatureFlagIsOn() {
        urlInterceptor = TabURLInterceptorDefault(featureFlagger: MockFeatureFlagger(enabledFeatureFlags: [.aiChatDeepLink]), canPurchase: { true })

        _ = self.expectation(forNotification: .urlInterceptAIChat, object: nil, handler: nil)

        let url = URL(string: "https://duckduckgo.com/?ia=chat")!
        let canNavigate = urlInterceptor.allowsNavigatingTo(url: url)

        XCTAssertFalse(canNavigate)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("Notification expectation failed: \(error)")
            }
        }
    }

    func testAllowsNavigationForAIChatPathWhenFeatureFlagIsOff() {
        urlInterceptor = TabURLInterceptorDefault(featureFlagger: MockFeatureFlagger(enabledFeatureFlags: []), canPurchase: { true })

        let url = URL(string: "https://duckduckgo.com/?ia=chat")!
        XCTAssertTrue(urlInterceptor.allowsNavigatingTo(url: url))
    }

}
