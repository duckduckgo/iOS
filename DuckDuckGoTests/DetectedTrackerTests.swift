//
//  DetectedTrackerTests.swift
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

class DetectedTrackerTests: XCTestCase {

    private struct Constants {
        static let aUrl = "www.example.com"
        static let anotherUrl = "www.anotherurl.com"
        static let aParentDomain = "adomain.com"
        static let anotherParentDomain = "anotherdomain.com"
        static let ipUrl = "http://192.168.0.1"
    }

    func testWhenUrlWithIPThenIPTracker() {
        let testee = DetectedTracker(url: Constants.ipUrl, networkName: Constants.aParentDomain, category: "Category", blocked: true)
        XCTAssertTrue(testee.isIpTracker)
    }

    func testWhenUrlWithDomainNotIPTracker() {
        let testee = DetectedTracker(url: Constants.aUrl, networkName: Constants.aParentDomain, category: "Category", blocked: true)
        XCTAssertFalse(testee.isIpTracker)
    }

    func testThatHashMatchesAndEqualsIsTrueWhenAllPropertiesAreSame() {
        let lhs = DetectedTracker(url: Constants.aUrl, networkName: Constants.aParentDomain, category: "Category", blocked: true)
        let rhs = DetectedTracker(url: Constants.aUrl, networkName: Constants.aParentDomain, category: "Category", blocked: true)
        XCTAssertEqual(lhs, rhs)
        XCTAssertEqual(lhs.hashValue, rhs.hashValue)
    }

    func testThatHashDoesntMatchAndEqualsFailsWhenBlockedDifferent() {
        let lhs = DetectedTracker(url: Constants.aUrl, networkName: Constants.aParentDomain, category: "Category", blocked: true)
        let rhs = DetectedTracker(url: Constants.aUrl, networkName: Constants.aParentDomain, category: "Category", blocked: false)
        XCTAssertNotEqual(lhs, rhs)
        XCTAssertNotEqual(lhs.hashValue, rhs.hashValue)
    }

    func testThatHashDoesntMatchAndEqualsFailsWhenUrlsDifferent() {
        let lhs = DetectedTracker(url: Constants.aUrl, networkName: Constants.aParentDomain, category: "Category", blocked: true)
        let rhs = DetectedTracker(url: Constants.anotherUrl, networkName: Constants.aParentDomain, category: "Category", blocked: true)
        XCTAssertNotEqual(lhs, rhs)
        XCTAssertNotEqual(lhs.hashValue, rhs.hashValue)
    }

    func testThatHashDoesntMatchEqualsFailsWhenNetworkNamesAreDifferent() {
        let lhs = DetectedTracker(url: Constants.aUrl, networkName: Constants.aParentDomain, category: "Category", blocked: true)
        let rhs = DetectedTracker(url: Constants.aUrl, networkName: Constants.anotherParentDomain, category: "Category", blocked: true)
        XCTAssertNotEqual(lhs, rhs)
        XCTAssertNotEqual(lhs.hashValue, rhs.hashValue)
    }

    func testThatHashDoesntMatchEqualsFailsWhenCategoriesAreDifferent() {
        let lhs = DetectedTracker(url: Constants.aUrl, networkName: Constants.aParentDomain, category: "Category 1", blocked: true)
        let rhs = DetectedTracker(url: Constants.aUrl, networkName: Constants.anotherParentDomain, category: "Category 2", blocked: true)
        XCTAssertNotEqual(lhs, rhs)
        XCTAssertNotEqual(lhs.hashValue, rhs.hashValue)
    }

}
