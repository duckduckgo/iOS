//
//  StoredLoginsTests.swift
//  UnitTests
//
//  Created by Chris Brind on 22/01/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import XCTest
@testable import Core

class StoredLoginsTests: XCTestCase {
    
    let userDefaults = UserDefaults(suiteName: "test")!
    
    override func setUp() {
        userDefaults.removePersistentDomain(forName: "test")
    }
    
    func testWhenClearIsCalledThenDomainsAreRemoved() {

        let logins = StoredLogins(userDefaults: userDefaults)
        logins.add(domain: "www.example.com")
        logins.clear()
        XCTAssertTrue(logins.allowedDomains.isEmpty)
        XCTAssertTrue(StoredLogins(userDefaults: userDefaults).allowedDomains.isEmpty)

    }
    
    func testWhenDuplicateDomainAddedThenUniqueDomainsPersisted() {

        let logins = StoredLogins(userDefaults: userDefaults)
        logins.add(domain: "www.example.com")
        logins.add(domain: "www.example.com")
        XCTAssertEqual(["www.example.com"], logins.allowedDomains)

    }

    func testWhenUserDecisionIsChangedThenItIsPersisted() {
        
        let logins = StoredLogins(userDefaults: userDefaults)
        logins.userDecision = .unknown
        XCTAssertEqual(logins.userDecision, .unknown)
        XCTAssertEqual(StoredLogins(userDefaults: userDefaults).userDecision, .unknown)
        
    }

    /// Existing users get the same behaviour as always
    func testWhenNewThenDefaultUserDecisionIsForgetAll() {
        
        let logins = StoredLogins(userDefaults: userDefaults)
        XCTAssertEqual(logins.userDecision, .forgetAll)
        
    }

    func testWhenPersistedThenStoredUnderExpectedKey() {
        
        let logins = StoredLogins(userDefaults: userDefaults)
        logins.add(domain: "www.example.com")
        XCTAssertEqual(["www.example.com"], userDefaults.array(forKey: StoredLogins.Constants.allowedDomainsKey) as? [String])
        
    }

    func testWhenDomainAddedThenItIsPersisted() {
        
        let logins = StoredLogins(userDefaults: userDefaults)
        logins.add(domain: "www.example.com")
        XCTAssertEqual(["www.example.com"], logins.allowedDomains)
        XCTAssertEqual(["www.example.com"], StoredLogins(userDefaults: userDefaults).allowedDomains)
    
    }
    
    func testWhenAllowedDomainsIsNewThenIsEmpty() {
        
        let logins = StoredLogins(userDefaults: userDefaults)
        XCTAssertTrue(logins.allowedDomains.isEmpty)
        
    }
    
}
