//
//  ServerTrustCache.swift
//  Core
//
//  Created by Christopher Brind on 09/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public class ServerTrustCache {

    public static let shared = ServerTrustCache()

    var cache = [String: SecTrust]()

    public func get(forDomain domain: String) -> SecTrust? {
        return cache[domain]
    }

    public func put(serverTrust: SecTrust, forDomain domain: String) {
        print("***", #function, "updating serverTrust for", domain)
        cache[domain] = serverTrust
    }

}
