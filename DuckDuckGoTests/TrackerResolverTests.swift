//
//  TrackerResolverTests.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import TrackerRadarKit
@testable import Core

class TrackerResolverTests: XCTestCase {

    func testWhenOptionsAreEmptyThenNothingMatches() {

        let rule = KnownTracker.Rule.Matching(domains: [], types: [])

        let urlOne = URL(string: "https://www.one.com")!

        XCTAssertFalse(TrackerResolver.isMatching(rule,
                                                 host: urlOne.host!,
                                                 resourceType: "image"))
    }

    func testWhenDomainsAreRequiredThenTypesDoNotMatter() {

        let rule = KnownTracker.Rule.Matching(domains: ["one.com", "two.com"], types: nil)

        let urlOne = URL(string: "https://www.one.com")!
        let urlTwo = URL(string: "https://two.com")!
        let urlThree = URL(string: "https://www.three.com")!

        XCTAssertTrue(TrackerResolver.isMatching(rule,
                                                 host: urlOne.host!,
                                                 resourceType: "image"))
        XCTAssertTrue(TrackerResolver.isMatching(rule,
                                                 host: urlTwo.host!,
                                                 resourceType: "image"))
        XCTAssertFalse(TrackerResolver.isMatching(rule,
                                                  host: urlThree.host!,
                                                  resourceType: "image"))
    }

    func testWhenTypesAreRequiredThenDomainsDoNotMatter() {

        let rule = KnownTracker.Rule.Matching(domains: [], types: ["image", "script"])

        let urlOne = URL(string: "https://www.one.com")!
        let urlTwo = URL(string: "https://two.com")!
        let urlThree = URL(string: "https://www.three.com")!

        XCTAssertTrue(TrackerResolver.isMatching(rule,
                                                 host: urlOne.host!,
                                                 resourceType: "image"))
        XCTAssertTrue(TrackerResolver.isMatching(rule,
                                                 host: urlTwo.host!,
                                                 resourceType: "script"))
        XCTAssertFalse(TrackerResolver.isMatching(rule,
                                                 host: urlThree.host!,
                                                 resourceType: "link"))
        XCTAssertTrue(TrackerResolver.isMatching(rule,
                                                 host: urlThree.host!,
                                                 resourceType: "image"))
    }

    func testWhenTypesAndDomainsAreRequiredThenItIsAnAndRequirement() {

        let rule = KnownTracker.Rule.Matching(domains: ["one.com", "two.com"], types: ["image", "script"])

        let urlOne = URL(string: "https://www.one.com")!
        let urlTwo = URL(string: "https://two.com")!
        let urlThree = URL(string: "https://www.three.com")!

        XCTAssertTrue(TrackerResolver.isMatching(rule,
                                                 host: urlOne.host!,
                                                 resourceType: "image"))
        XCTAssertFalse(TrackerResolver.isMatching(rule,
                                                 host: urlOne.host!,
                                                 resourceType: "link"))
        XCTAssertTrue(TrackerResolver.isMatching(rule,
                                                 host: urlOne.host!,
                                                 resourceType: "script"))

        XCTAssertTrue(TrackerResolver.isMatching(rule,
                                                 host: urlTwo.host!,
                                                 resourceType: "script"))
        XCTAssertFalse(TrackerResolver.isMatching(rule,
                                                 host: urlTwo.host!,
                                                 resourceType: "link"))

        XCTAssertFalse(TrackerResolver.isMatching(rule,
                                                 host: urlThree.host!,
                                                 resourceType: "link"))
        XCTAssertFalse(TrackerResolver.isMatching(rule,
                                                 host: urlThree.host!,
                                                 resourceType: "image"))
    }

}
