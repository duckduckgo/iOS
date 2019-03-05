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
    
    func testWhenFeatureNotEnabledThenInstanciationFails() {
        
        let delegate = MockBrowsingTipsDelegate()
        let storage = MockContextualTipsStorage()
        let variantManager = MockVariantManager()
        let tips = BrowsingTips(delegate: delegate, storage: storage, variantManager: variantManager)
        XCTAssertNil(tips)
        
    }
    
    func testWhenTipsTriggeredWithDDGURLAndNoErrorThenDelegateNotCalled() {
        
        let delegate = MockBrowsingTipsDelegate()
        let storage = MockContextualTipsStorage()
        var variantManager = MockVariantManager()
        variantManager.currentVariant = Variant(name: "", weight: 0, features: [ .onboardingContextual ])
        let tips = BrowsingTips(delegate: delegate, storage: storage, variantManager: variantManager)
        
        tips?.onFinishedLoading(url: URLs.ddg, error: false)
        XCTAssertEqual(0, delegate.showPrivacyGradeTipCounter)
        XCTAssertEqual(0, delegate.showFireButtonTipCounter)

    }

    func testWhenTipsTriggeredWithValidURLAndErrorThenDelegateNotCalled() {
        
        let delegate = MockBrowsingTipsDelegate()
        let storage = MockContextualTipsStorage()
        var variantManager = MockVariantManager()
        variantManager.currentVariant = Variant(name: "", weight: 0, features: [ .onboardingContextual ])
        let tips = BrowsingTips(delegate: delegate, storage: storage, variantManager: variantManager)

        tips?.onFinishedLoading(url: URLs.example, error: true)
        XCTAssertEqual(0, delegate.showPrivacyGradeTipCounter)
        XCTAssertEqual(0, delegate.showFireButtonTipCounter)

    }

    func testWhenTipsTriggeredWithValidURLAndNoErrorThenDelegateCalledCorrectNumberOfTimes() {
        
        let delegate = MockBrowsingTipsDelegate()
        let storage = MockContextualTipsStorage()
        var variantManager = MockVariantManager()
        variantManager.isSupportedReturns = true
        let tips = BrowsingTips(delegate: delegate, storage: storage, variantManager: variantManager)
        XCTAssertEqual(0, delegate.showPrivacyGradeTipCounter)
        XCTAssertEqual(0, delegate.showFireButtonTipCounter)
        
        tips?.onFinishedLoading(url: URLs.example, error: false)
        XCTAssertEqual(0, delegate.showFireButtonTipCounter)
        XCTAssertEqual(1, delegate.showPrivacyGradeTipCounter)
        
        tips?.onFinishedLoading(url: URLs.example, error: false)
        XCTAssertEqual(1, delegate.showFireButtonTipCounter)
        XCTAssertEqual(1, delegate.showPrivacyGradeTipCounter)
        
        tips?.onFinishedLoading(url: URLs.example, error: false)
        XCTAssertEqual(1, delegate.showFireButtonTipCounter)
        XCTAssertEqual(1, delegate.showPrivacyGradeTipCounter)
    }
    
}

class MockBrowsingTipsDelegate: NSObject, BrowsingTipsDelegate {
    
    var showPrivacyGradeTipCounter = 0
    var showFireButtonTipCounter = 0
    
    func showPrivacyGradeTip() {
        showPrivacyGradeTipCounter += 1
    }
    
    func showFireButtonTip() {
        showFireButtonTipCounter += 1
    }
    
}
