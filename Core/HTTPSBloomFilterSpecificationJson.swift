//
//  HTTPSBloomFilterJsonSpecification.swift
//  Core
//
//  Created by duckduckgo on 20/08/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import Foundation

struct HTTPSTransientBloomFilterSpecification {
    let totalEntries: Int
    let errorRate: Double
    let sha256: String
    
    func isEqualTo(storedSpecification: HTTPSBloomFilterSpecification) {
        return totalItems == storedSpecification.totalEntries &&
            errorRate == storedSpecification.errorRate &&
            sha256 == storedSpecification.sha256
    }
}
