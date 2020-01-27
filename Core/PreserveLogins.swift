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
        static let detectedDomainsKey = "com.duckduckgo.ios.PreserveLogins.userDecision.detectedDomains"
        static let allowedDomainsKey = "com.duckduckgo.ios.PreserveLogins.userDecision.allowedDomains"
        static let userDecisionKey = "com.duckduckgo.ios.PreserveLogins.userDecision"
        static let userPromptedKey = "com.duckduckgo.ios.PreserveLogins.userPrompted"
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

    private(set) public var detectedDomains: [String] {
        get {
            return userDefaults.array(forKey: Constants.detectedDomainsKey) as? [String] ?? []
        }
        
        set {
            let domains = [String](Set<String>(newValue))
            userDefaults.set(domains, forKey: Constants.detectedDomainsKey)
        }
    }

    public var userDecision: UserDecision {
        get {
            return UserDecision(rawValue: userDefaults.integer(forKey: Constants.userDecisionKey))!
        }
        
        set {
            userDefaults.set(newValue.rawValue, forKey: Constants.userDecisionKey)
            if newValue == .preserveLogins {
                allowedDomains = detectedDomains
                detectedDomains = []
            } else {
                detectedDomains = allowedDomains
                allowedDomains = []
            }
        }
    }
    
    public var prompted: Bool {
        get {
            return userDefaults.bool(forKey: Constants.userPromptedKey)
        }
        
        set {
            userDefaults.set(newValue, forKey: Constants.userPromptedKey)
        }
    }

    private var userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    public func add(domain: String) {
        if userDecision == .preserveLogins {
            allowedDomains += [domain]
        } else {
            detectedDomains += [domain]
        }
    }

    public func isAllowed(cookieDomain: String) -> Bool {

        return allowedDomains.contains(where: { $0 == cookieDomain
            || ".\($0)" == cookieDomain
            || (cookieDomain.hasPrefix(".") && $0.hasSuffix(cookieDomain)) })
        
    }

    public func remove(domain: String) {
        allowedDomains = allowedDomains.filter { $0 != domain }
    }

    public func clearAll() {
        detectedDomains = []
        allowedDomains = []
    }
    
    public func clearDetected() {
        detectedDomains = []
    }

}
