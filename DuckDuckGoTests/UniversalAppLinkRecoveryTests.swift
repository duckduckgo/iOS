//
//  UniversalAppLinkRecoveryTests.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
@testable import Core

class UniversalAppLinkRecoveryTests: XCTestCase {

    private var testee: UniversalAppLinkRecovery!

    override func setUp() {
        testee = UniversalAppLinkRecovery()
    }

    func testWhenAppBackgroundedAfterWebpageDidStartLoadingBehaviorIsNone() {

        testee.waitingForLoadAfterAllowPolicyDecision = true
        testee.finishedWithError = true
        testee.webpageDidStartLoading()
        XCTAssertEqual(testee.appBackgrounded(), UniversalAppLinkRecovery.Behavior.none)

    }

    func testWhenAppBackgroundedAndFinishedWithErrorBehaviorIsReload() {

        testee.finishedWithError = true
        XCTAssertEqual(testee.appBackgrounded(), UniversalAppLinkRecovery.Behavior.reload)

    }

    func testWhenAppBackgroundedWhileWaitingForLoadAfterPolicyAllowDecisionBehaviorIsGoBack() {

        testee.waitingForLoadAfterAllowPolicyDecision = true
        XCTAssertEqual(testee.appBackgrounded(), UniversalAppLinkRecovery.Behavior.goBack)

    }

    func testWhenAppBackgroundedBehaviorIsDoNothing() {
        XCTAssertEqual(testee.appBackgrounded(), UniversalAppLinkRecovery.Behavior.none)
    }

}
