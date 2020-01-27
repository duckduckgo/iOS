//
//  PreserveLoginsTests.swift
//  UnitTests
//
//  Created by Chris Brind on 22/01/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

    func testWhenPromptedIsChangedThenPersisted() {
        
        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.prompted = true
        XCTAssertTrue(logins.prompted)
        XCTAssertTrue(PreserveLogins(userDefaults: userDefaults).prompted)
        
    }

    func testWhenUserDecisionIsChangedThenItIsPersisted() {
        
        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.userDecision = .unknown
        XCTAssertEqual(logins.userDecision, .unknown)
        XCTAssertEqual(PreserveLogins(userDefaults: userDefaults).userDecision, .unknown)
        
    }

    /// Existing users get the same behaviour as always
    func testWhenNewThenDefaultPromptedIsFalse() {
        
        let logins = PreserveLogins(userDefaults: userDefaults)
        XCTAssertFalse(logins.prompted)
        
    }

    /// Existing users get the same behaviour as always
    func testWhenNewThenDefaultUserDecisionIsForgetAll() {
        
        let logins = PreserveLogins(userDefaults: userDefaults)
        XCTAssertEqual(logins.userDecision, .forgetAll)
        
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
