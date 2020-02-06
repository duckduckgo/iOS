//
//  PreserveLogins.swift
//  Core
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
                allowedDomains += detectedDomains
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

extension PreserveLogins {

    public var forgetAllPixelParameters: [String: String] {

        let value: String
        switch userDecision {
        case .forgetAll:
            value = "f"
        case .preserveLogins:
            value = "p"
        case .unknown:
            value = "u"
        }

        return [
            "pls": value,
            "plu": PreserveLogins.shared.prompted ? "n" : "e"
        ]
    }

}
