//
//  BrowserComparisonModelTests.swift
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

final class BrowserComparisonModelTests: XCTestCase {

    func testBrowserComparisonFeaturePrivateSearchIsCorrect() throws {
        // WHEN
        let result = try XCTUnwrap(BrowsersComparisonModel.privacyFeatures.first(where: { $0.type == .privateSearch })?.type.title)

        // THEN
        XCTAssertEqual(result, UserText.Onboarding.BrowsersComparison.Features.privateSearch)

    }

    func testBrowserComparisonFeatureBlockThirdPartyTrackersIsCorrect() throws {
        // WHEN
        let result = try XCTUnwrap(BrowsersComparisonModel.privacyFeatures.first(where: { $0.type == .blockThirdPartyTrackers })?.type.title)

        // THEN
        XCTAssertEqual(result, UserText.Onboarding.BrowsersComparison.Features.trackerBlockers)
    }

    func testBrowserComparisonFeatureBlockCookiePopupsIsCorrect() throws {
        // WHEN
        let result = try XCTUnwrap(BrowsersComparisonModel.privacyFeatures.first(where: { $0.type == .blockCookiePopups })?.type.title)

        // THEN
        XCTAssertEqual(result, UserText.Onboarding.BrowsersComparison.Features.cookiePopups)
    }

    func testBrowserComparisonFeatureBlockCreepyAdsIsCorrect() throws {
        // WHEN
        let result = try XCTUnwrap(BrowsersComparisonModel.privacyFeatures.first(where: { $0.type == .blockCreepyAds })?.type.title)

        // THEN
        XCTAssertEqual(result, UserText.Onboarding.BrowsersComparison.Features.creepyAds)
    }

    func testWhenIsNotHighlightsThenBrowserComparisonFeatureEraseBrowsingDataIsCorrect() throws {
        // WHEN
        let result = try XCTUnwrap(BrowsersComparisonModel.privacyFeatures.first(where: { $0.type == .eraseBrowsingData })?.type.title)

        // THEN
        XCTAssertEqual(result, UserText.Onboarding.BrowsersComparison.Features.eraseBrowsingData)
    }

}
