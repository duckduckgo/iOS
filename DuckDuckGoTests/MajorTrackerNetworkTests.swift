//
//  MajorTrackerNetworkTests.swift
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

class MajorTrackerNetworkTests: XCTestCase {

    func testWhenSearchingForNoneMajorNetworkByNameResultIsNil() {
        let store = EmbeddedMajorTrackerNetworkStore()
        XCTAssertNil(store.network(forName: "AKQA"))
    }

    func testWhenSearchingForNoneNetworkByDomainResultIsNil() {
        let store = EmbeddedMajorTrackerNetworkStore()
        XCTAssertNil(store.network(forDomain: "duckduckgo.com"))
    }

    func testWhenSearchingForNetworkWithDomainResultNotNil() {
        let store = EmbeddedMajorTrackerNetworkStore()
        XCTAssertNotNil(store.network(forDomain: "sub.google.com"))
        XCTAssertNotNil(store.network(forDomain: "www.google.com"))
        XCTAssertNotNil(store.network(forDomain: "GOOGLE.com"))
    }

    func testWhenSearchingForNetworkWithNameResultNotNil() {
        let store = EmbeddedMajorTrackerNetworkStore()
        XCTAssertNotNil(store.network(forName: "google"))
        XCTAssertNotNil(store.network(forName: "Google"))
        XCTAssertNotNil(store.network(forName: "GOOGLE"))
    }

}
