//
//  TLDTests.swift
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
@testable import DuckDuckGo
@testable import Core

class TLDTests: XCTestCase {

    let tld = TLD()

    func testWhenJsonAccessedThenReturnsValidJson() {
        let tlds = try? JSONDecoder().decode([String: Int].self, from: tld.json.data(using: .utf8)!)

        XCTAssertNotNil(tlds)
        XCTAssertFalse(tlds?.isEmpty ?? true)
    }

    func testWhenHostMultiPartTopLevelWithSubdomainThenDomainCorrect() {
        XCTAssertEqual("bbc.co.uk", tld.domain("www.bbc.co.uk"))
        XCTAssertEqual("bbc.co.uk", tld.domain("other.bbc.co.uk"))
        XCTAssertEqual("bbc.co.uk", tld.domain("multi.part.bbc.co.uk"))
    }

    func testWhenHostDotComWithSubdomainThenDomainIsTopLevel() {
        XCTAssertEqual("example.com", tld.domain("www.example.com"))
        XCTAssertEqual("example.com", tld.domain("other.example.com"))
        XCTAssertEqual("example.com", tld.domain("multi.part.example.com"))
    }

    func testWhenHostIsTopLevelDotComThenDomainIsSame() {
        XCTAssertEqual("example.com", tld.domain("example.com"))
    }

    func testWhenHostIsNilDomainIsNil() {
        XCTAssertNil(tld.domain(nil))
    }

    func testWhenTLDInstanciatedThenLoadsTLDData() {
        XCTAssertFalse(tld.tlds.isEmpty)
    }

}
