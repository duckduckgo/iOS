//
//  BrowsingTipsTests.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo

class BrowsingTipsTests: XCTestCase {
    
    struct URLs {
        
        static let example = URL(string: "https://example.com")
        static let ddg = URL(string: "https://duckduckgo.com")
        
    }
    
    // swiftlint:disable weak_delegate
    let delegate = MockBrowsingTipsDelegate()
    // swiftlint:enable weak_delegate
    var storage = MockContextualTipsStorage()

    func testWhenNotShownThenNextTipIsUnchanged() {
        
        storage.isEnabled = true
        delegate.shown = false
        
        let tips = BrowsingTips(delegate: delegate, storage: storage)
        XCTAssertNotNil(tips)
        
        tips?.onFinishedLoading(url: URLs.example, error: false)
        XCTAssertEqual(1, delegate.showPrivacyGradeTipCounter)
        XCTAssertEqual(0, delegate.showFireButtonTipCounter)
        
        XCTAssertEqual(0, storage.nextBrowsingTip)
    }

    func testWhenFeatureNotEnabledThenInstanciationFails() {
        
        let tips = BrowsingTips(delegate: delegate, storage: storage)
        XCTAssertNil(tips)
        
    }
    
    func testWhenTipsTriggeredWithDDGURLAndNoErrorThenDelegateNotCalled() {
        
        storage.isEnabled = true
        let tips = BrowsingTips(delegate: delegate, storage: storage)
        XCTAssertNotNil(tips)
        
        tips?.onFinishedLoading(url: URLs.ddg, error: false)
        XCTAssertEqual(0, delegate.showPrivacyGradeTipCounter)
        XCTAssertEqual(0, delegate.showFireButtonTipCounter)

    }

    func testWhenTipsTriggeredWithValidURLAndErrorThenDelegateNotCalled() {
        
        storage.isEnabled = true
        let tips = BrowsingTips(delegate: delegate, storage: storage)
        XCTAssertNotNil(tips)

        tips?.onFinishedLoading(url: URLs.example, error: true)
        XCTAssertEqual(0, delegate.showPrivacyGradeTipCounter)
        XCTAssertEqual(0, delegate.showFireButtonTipCounter)

    }

    func testWhenTipsTriggeredWithValidURLAndNoErrorThenDelegateCalledCorrectNumberOfTimes() {
        
        storage.isEnabled = true
        let tips = BrowsingTips(delegate: delegate, storage: storage)
        XCTAssertEqual(0, delegate.showPrivacyGradeTipCounter)
        XCTAssertEqual(0, delegate.showFireButtonTipCounter)
        XCTAssertEqual(0, storage.nextBrowsingTip)

        tips?.onFinishedLoading(url: URLs.example, error: false)
        XCTAssertEqual(0, delegate.showFireButtonTipCounter)
        XCTAssertEqual(1, delegate.showPrivacyGradeTipCounter)
        XCTAssertEqual(1, storage.nextBrowsingTip)

        tips?.onFinishedLoading(url: URLs.example, error: false)
        XCTAssertEqual(1, delegate.showFireButtonTipCounter)
        XCTAssertEqual(1, delegate.showPrivacyGradeTipCounter)
        XCTAssertEqual(2, storage.nextBrowsingTip)

        tips?.onFinishedLoading(url: URLs.example, error: false)
        XCTAssertEqual(1, delegate.showFireButtonTipCounter)
        XCTAssertEqual(1, delegate.showPrivacyGradeTipCounter)
        XCTAssertEqual(2, storage.nextBrowsingTip)
    }
    
    func testWhenTipsDisabledLaterThenTriggerDoesNothing() {
        
        storage.isEnabled = true
        let tips = BrowsingTips(delegate: delegate, storage: storage)
        XCTAssertNotNil(tips)
        
        storage.isEnabled = false
        tips?.onFinishedLoading(url: URLs.example, error: false)
        XCTAssertEqual(0, delegate.showPrivacyGradeTipCounter)
        XCTAssertEqual(0, delegate.showFireButtonTipCounter)

    }
    
}

class MockBrowsingTipsDelegate: NSObject, BrowsingTipsDelegate {
    
    var shown = true
    var showPrivacyGradeTipCounter = 0
    var showFireButtonTipCounter = 0
    
    func showPrivacyGradeTip(didShow: (Bool) -> Void) {
        showPrivacyGradeTipCounter += 1
        didShow(shown)
    }
    
    func showFireButtonTip(didShow: (Bool) -> Void) {
        showFireButtonTipCounter += 1
        didShow(shown)
    }
    
}
