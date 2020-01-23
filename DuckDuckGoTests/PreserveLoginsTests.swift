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
    
    func testWhenClearIsCalledThenDomainsAreRemoved() {

        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.add(domain: "www.example.com")
        logins.clear()
        XCTAssertTrue(logins.allowedDomains.isEmpty)
        XCTAssertTrue(PreserveLogins(userDefaults: userDefaults).allowedDomains.isEmpty)

    }
    
    func testWhenDuplicateDomainAddedThenUniqueDomainsPersisted() {

        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.add(domain: "www.example.com")
        logins.add(domain: "www.example.com")
        XCTAssertEqual(["www.example.com"], logins.allowedDomains)

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

    func testWhenPersistedThenStoredUnderExpectedKey() {
        
        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.add(domain: "www.example.com")
        XCTAssertEqual(["www.example.com"], userDefaults.array(forKey: PreserveLogins.Constants.allowedDomainsKey) as? [String])
        
    }

    func testWhenDomainAddedThenItIsPersisted() {
        
        let logins = PreserveLogins(userDefaults: userDefaults)
        logins.add(domain: "www.example.com")
        XCTAssertEqual(["www.example.com"], logins.allowedDomains)
        XCTAssertEqual(["www.example.com"], PreserveLogins(userDefaults: userDefaults).allowedDomains)
    
    }
    
    func testWhenNewThenAllowedDomainsIsEmpty() {
        
        let logins = PreserveLogins(userDefaults: userDefaults)
        XCTAssertTrue(logins.allowedDomains.isEmpty)
        
    }
    
}
