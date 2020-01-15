//
//  KnownTrackerTests.swift
//  UnitTests
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

class KnownTrackerTests: XCTestCase {

    func testWhenCategoriesIsPopulatedWithApprovedCategoryThenCategoryIsFirstApproved() {
        let tracker = KnownTracker(domain: nil, defaultAction: nil, owner: nil, prevalence: nil, subdomains: nil, categories: [
            "one", "Advertising", "three"
        ], rules: nil)
        XCTAssertEqual("Advertising", tracker.category)
    }

    func testWhenCategoriesIsPopulatedWithUnapprovedCategoriesThenCategoryIsNil() {
        let tracker = KnownTracker(domain: nil, defaultAction: nil, owner: nil, prevalence: nil, subdomains: nil, categories: [
            "one", "two", "three"
        ], rules: nil)
        XCTAssertNil(tracker.category)
    }

    func testWhenCategoriesIsEmptyThenCategoryIsNil() {
        let tracker = KnownTracker(domain: nil, defaultAction: nil, owner: nil, prevalence: nil, subdomains: nil, categories: [], rules: nil)
        XCTAssertNil(tracker.category)
    }

    func testWhenCategoriesIsNilThenCategoryIsNil() {
        let tracker = KnownTracker(domain: nil, defaultAction: nil, owner: nil, prevalence: nil, subdomains: nil, categories: nil, rules: nil)
        XCTAssertNil(tracker.category)
    }

}
