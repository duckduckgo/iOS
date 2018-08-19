//
//  HTTPSBloomFilterJsonSpecification.swift
//  Core
//
//  Created by duckduckgo on 20/08/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import Foundation

public struct HTTPSTransientBloomFilterSpecification {
    let totalEntries: Int
    let errorRate: Double
    let sha256: String
    
    func isEqualTo(storedSpecification: HTTPSBloomFilterSpecification?) -> Bool {
        
        guard let storedSpecification = storedSpecification else { return false }
        
        return totalEntries == storedSpecification.totalEntries &&
            errorRate == storedSpecification.errorRate &&
            sha256 == storedSpecification.sha256
    }
}
