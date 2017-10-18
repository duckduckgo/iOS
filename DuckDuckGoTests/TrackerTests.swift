//
//  TrackerTests.swift
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

class TrackerTests: XCTestCase {
    
    private struct Constants {
        static let aUrl = "www.example.com"
        static let anotherUrl = "www.anotherurl.com"
        static let aParentDomain = "adomain.com"
        static let anotherParentDomain = "anotherdomain.com"
    }
    
    func testThatEqualsIsTrueWhenUrlsDomainAndCategoryAreSame() {
        let lhs = Tracker(url: Constants.aUrl, parentDomain: Constants.aParentDomain, category: .analytics)
        let rhs = Tracker(url: Constants.aUrl, parentDomain: Constants.aParentDomain, category: .analytics)
        XCTAssertEqual(lhs, rhs)
    }
    
    func testThatEqualsFailsWhenUrlsDifferent() {
        let lhs = Tracker(url: Constants.aUrl, parentDomain: Constants.aParentDomain, category: .analytics)
        let rhs = Tracker(url: Constants.anotherUrl, parentDomain: Constants.aParentDomain, category: .analytics)
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testThatEqualsFailsWhenDomainsDifferent() {
        let lhs = Tracker(url: Constants.aUrl, parentDomain: Constants.aParentDomain, category: .analytics)
        let rhs = Tracker(url: Constants.aUrl, parentDomain: Constants.anotherParentDomain, category: .analytics)
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testThatEqualsFailsWhenCategoriesAreDifferent() {
        let lhs = Tracker(url: Constants.aUrl, parentDomain: Constants.aParentDomain, category: .analytics)
        let rhs = Tracker(url: Constants.aUrl, parentDomain: Constants.anotherParentDomain, category: .social)
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testThatEqualsFailsWhenTypesAreDifferent() {
        let tracker = Tracker(url: Constants.aUrl, parentDomain: Constants.aParentDomain)
        XCTAssertFalse(tracker.isEqual(NSObject()))
    }

    func testHashIsSameWhenItemsAreEqual() {
        let lhs = Tracker(url: Constants.aUrl, parentDomain: Constants.aParentDomain)
        let rhs = Tracker(url: Constants.aUrl, parentDomain: Constants.aParentDomain)
        XCTAssertEqual(lhs, rhs)
        XCTAssertEqual(lhs.hashValue, rhs.hashValue)
    }
    
    func testMajorNetworkTrueWhenTrackerFromMajorNetwork() {
        let testee = Tracker(url: "example.com", parentDomain: "facebook.com")
        XCTAssertTrue(testee.fromMajorNetwork)
    }
    
    func testMajorNetworkFalseWhenTrackerNotFromMajorNetwork() {
        let testee = Tracker(url: "example.com", parentDomain: "someSmallAdNetwork.com")
        XCTAssertFalse(testee.fromMajorNetwork)
    }
    
    func testMajorNetworkFalseWhenTrackerHasNoParentDomain() {
        let testee = Tracker(url: "example.com", parentDomain: nil)
        XCTAssertFalse(testee.fromMajorNetwork)
    }
}
