//
//  StoredLogins.swift
//  Core
//
//  Created by Chris Brind on 15/01/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Foundation

public class StoredLogins {
    
    struct Constants {
        static let key = "com.duckduckgo.ios.StoredLogins"
    }
    
    public static let shared = StoredLogins()
    
    private var userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    private(set) public var allowedDomains: [String] {
        get {
            return userDefaults.array(forKey: Constants.key) as? [String] ?? []
        }
        
        set {
            let domains = [String](Set<String>(newValue))
            userDefaults.set(domains, forKey: Constants.key)
        }
    }

    public func add(domain: String) {
        allowedDomains += [domain]
    }
    
    public func clear() {
        allowedDomains = [] 
    }
    
}
