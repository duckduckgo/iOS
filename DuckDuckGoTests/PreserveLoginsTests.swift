//
//  PreserveLoginsTests.swift
//  UnitTests
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

class PreserveLoginsTests: XCTestCase {
    
    let userDefaults = UserDefaults(suiteName: "test")!
    
    override func setUp() {
        userDefaults.removePersistentDomain(forName: "test")
    }

    func testWhenDomainWithSubdomainMatchesWildcardThenIsAllowed() {

        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.userDecision = .preserveLogins
        logins.add(domain: "www.boardgamegeek.com")
        XCTAssertTrue(logins.isAllowed(cookieDomain: ".boardgamegeek.com"))

    }

    func testWhenDomainMatchesWildcardThenIsAllowed() {

        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.userDecision = .preserveLogins
        logins.add(domain: "boardgamegeek.com")
        XCTAssertTrue(logins.isAllowed(cookieDomain: ".boardgamegeek.com"))

    }

    func testWhenDomainMatchesThenIsAllowed() {

        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.userDecision = .preserveLogins
        logins.add(domain: "boardgamegeek.com")
        XCTAssertTrue(logins.isAllowed(cookieDomain: "boardgamegeek.com"))

    }
    
    func testWhenUserDisablesPreserveLoginsThenAllowedDomainsAreMovedToDetectedDomains() {

        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.userDecision = .preserveLogins
        logins.add(domain: "www.example.com")
        XCTAssertEqual(["www.example.com"], logins.allowedDomains)
        XCTAssertTrue(logins.detectedDomains.isEmpty)
        
        logins.userDecision = .forgetAll
        XCTAssertEqual(["www.example.com"], logins.detectedDomains)
        XCTAssertTrue(logins.allowedDomains.isEmpty)
    }

    func testWhenUserEnablesPreserveLoginsThenDetectedDomainsAreMovedToAllowedDomains() {

        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.add(domain: "www.example.com")
        XCTAssertEqual(["www.example.com"], logins.detectedDomains)
        XCTAssertTrue(logins.allowedDomains.isEmpty)

        logins.userDecision = .preserveLogins
        XCTAssertEqual(["www.example.com"], logins.allowedDomains)
        XCTAssertTrue(logins.detectedDomains.isEmpty)
        
    }
    
    func testWhenClearAllIsCalledThenAllowDomainsAreCleared() {

        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.userDecision = .preserveLogins
        logins.add(domain: "www.example.com")
        logins.clearAll()
        XCTAssertTrue(logins.detectedDomains.isEmpty)
        XCTAssertTrue(logins.allowedDomains.isEmpty)
        
        logins.userDecision = .forgetAll
        logins.add(domain: "www.example.com")
        logins.clearAll()
        XCTAssertTrue(logins.detectedDomains.isEmpty)
        XCTAssertTrue(logins.allowedDomains.isEmpty)
        
    }
    
    func testWhenClearDetectedIsCalledThenDetectedDomainsAreCleared() {

        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.add(domain: "www.example.com")
        logins.clearDetected()
        XCTAssertTrue(logins.allowedDomains.isEmpty)
        XCTAssertTrue(logins.detectedDomains.isEmpty)

    }

    func testWhenDuplicateDomainWhenPreserveLoginsIsSelectedAddedThenUniqueDomainsPersistedToAllowedDomains() {

        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.userDecision = .preserveLogins
        logins.add(domain: "www.example.com")
        logins.add(domain: "www.example.com")
        XCTAssertEqual(["www.example.com"], logins.allowedDomains)

    }

    func testWhenDuplicateDomainWhenPreserveLoginsIsNotSelectedAddedThenUniqueDomainsPersistedToDetectedDomains() {

        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.add(domain: "www.example.com")
        logins.add(domain: "www.example.com")
        XCTAssertEqual(["www.example.com"], logins.detectedDomains)

    }
    
    func testWhenUserDecisionIsChangedToOtherThanPreserveLoginsThenDomainsAreCleared() {
        
        let logins = PreserveLogins(userDefaults: userDefaults)
        
        logins.add(domain: "www.example.com")
        logins.userDecision = .preserveLogins
        XCTAssertFalse(logins.allowedDomains.isEmpty)
        
        logins.add(domain: "www.example.com")
        logins.userDecision = .forgetAll
        XCTAssertTrue(logins.allowedDomains.isEmpty)

        logins.add(domain: "www.example.com")
        logins.userDecision = .preserveLogins
        XCTAssertFalse(logins.allowedDomains.isEmpty)

        logins.add(domain: "www.example.com")
        logins.userDecision = .unknown
        XCTAssertTrue(logins.allowedDomains.isEmpty)

    }

    func testWhenUserDecisionIsChangedThenItIsPersisted() {
        
        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.userDecision = .unknown
        XCTAssertEqual(logins.userDecision, .unknown)
        XCTAssertEqual(PreserveLogins(userDefaults: userDefaults).userDecision, .unknown)
        
    }

    func testWhenNewThenDefaultIsUnkonwn() {
        
        let logins = PreserveLogins(userDefaults: userDefaults)
        XCTAssertEqual(logins.userDecision, .unknown)
        
    }

    func testWhenDomainAddedWhenNotPreservingLoginsThenItIsPersistedToDetectedDomains() {
        
        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.add(domain: "www.example.com")
        XCTAssertEqual(["www.example.com"], logins.detectedDomains)
        XCTAssertEqual(["www.example.com"], PreserveLogins(userDefaults: userDefaults).detectedDomains)
    
    }

    func testWhenDomainAddedWhenPreservingLoginsThenItIsPersistedToAllowedDomains() {
        
        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.userDecision = .preserveLogins
        logins.add(domain: "www.example.com")
        XCTAssertEqual(["www.example.com"], logins.allowedDomains)
        XCTAssertEqual(["www.example.com"], PreserveLogins(userDefaults: userDefaults).allowedDomains)
    
    }
    
    func testWhenNewThenAllowedDomainsIsEmpty() {
        
        let logins = PreserveLogins(userDefaults: userDefaults)
        XCTAssertTrue(logins.allowedDomains.isEmpty)
        
    }
    
}
