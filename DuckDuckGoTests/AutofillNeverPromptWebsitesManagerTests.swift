//
//  AutofillNeverPromptWebsitesManagerTests.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit

final class AutofillNeverPromptWebsitesManagerTests: XCTestCase {

    private var manager: AutofillNeverPromptWebsitesManager!
    private let vault = (try? MockSecureVaultFactory.makeVault(errorReporter: nil))!

    override func setUpWithError() throws {
        try super.setUpWithError()
        manager = AutofillNeverPromptWebsitesManager(secureVault: vault)
    }

    override func tearDownWithError() throws {
        manager = nil

        try super.tearDownWithError()
    }

    func testWhenSavingNeverPromptWebsiteThenHasNeverPromptWebsiteForDomain() throws {
        let domain = "example.com"
        _ = try manager.saveNeverPromptWebsite(domain)

        let result = manager.hasNeverPromptWebsitesFor(domain: domain)

        XCTAssertTrue(result)
    }

    func testWhenMultipleNeverPromptWebsitesThenHasNeverPromptWebsiteForDomain() {
        XCTAssertTrue(manager.deleteAllNeverPromptWebsites())

        XCTAssertNoThrow(try manager.saveNeverPromptWebsite("example.com"))
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite("sub.example.com"))
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite("anotherdomain.com"))

        XCTAssertEqual(manager.neverPromptWebsites.count, 3)
        XCTAssertTrue(manager.hasNeverPromptWebsitesFor(domain: "example.com"))
    }

    func testWhenDeletingAllNeverPromptWebsitesTheAllNeverPromptWebsitesDeleted() {
        XCTAssertTrue(manager.deleteAllNeverPromptWebsites())

        let domain = "example.com"
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite(domain))
        XCTAssertEqual(manager.neverPromptWebsites.count, 1)

        XCTAssertTrue(manager.deleteAllNeverPromptWebsites())
        XCTAssertEqual(manager.neverPromptWebsites.count, 0)
    }

    func testWhenNoNeverPromptWebsitesForDomainThenNoHasNeverPromptWebsitesForDomain() {
        let domain = "example.com"
        XCTAssertTrue(manager.deleteAllNeverPromptWebsites())
        XCTAssertFalse(manager.hasNeverPromptWebsitesFor(domain: domain))
    }

    func testWhenSaveNeverPromptWebsiteThatAlreadyExistsThenHasNeverPromptWebsiteForDomain() {
        let domain = "example.com"
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite(domain))
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite(domain))
        XCTAssertTrue(manager.hasNeverPromptWebsitesFor(domain: "example.com"))
    }

}
