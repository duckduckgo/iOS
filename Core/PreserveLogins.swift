//
//  PreservedLogins.swift
//  Core
//
//  Created by Chris Brind on 15/01/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Foundation

public class PreserveLogins {
    
    public enum UserDecision: Int {
        
        case forgetAll = 0 // this is the default so that existing users have same behaviour
        case preserveLogins
        case unknown

    }
    
    struct Constants {
        static let allowedDomainsKey = "com.duckduckgo.ios.PreserveLogins.userDecision.allowedDomains"
        static let userDecisionKey = "com.duckduckgo.ios.PreserveLogins.userDecision"
    }
    
    public static let shared = PreserveLogins()
    
    private(set) public var allowedDomains: [String] {
        get {
            return userDefaults.array(forKey: Constants.allowedDomainsKey) as? [String] ?? []
        }
        
        set {
            let domains = [String](Set<String>(newValue))
            userDefaults.set(domains, forKey: Constants.allowedDomainsKey)
        }
    }
    
    public var userDecision: UserDecision {
        get {
            return UserDecision(rawValue: userDefaults.integer(forKey: Constants.userDecisionKey))!
        }
        
        set {
            userDefaults.set(newValue.rawValue, forKey: Constants.userDecisionKey)
            if newValue != .preserveLogins {
                allowedDomains = []
            }
        }
    }

    private var userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    public func add(domain: String) {
        allowedDomains += [domain]
    }
    
    public func clear() {
        allowedDomains = [] 
    }
    
}
