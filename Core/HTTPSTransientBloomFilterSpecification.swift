//
//  HTTPSTransientBloomFilterSpecification.swift
//  Core
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

public struct HTTPSTransientBloomFilterSpecification: Equatable {
    let totalEntries: Int
    let errorRate: Double
    let sha256: String
    
    static public func == (lhs: HTTPSTransientBloomFilterSpecification, rhs: HTTPSTransientBloomFilterSpecification) -> Bool {
        return lhs.totalEntries == rhs.totalEntries && lhs.errorRate == rhs.errorRate && lhs.sha256 == rhs.sha256
    }
    
    static func copy(storedSpecification specification: HTTPSBloomFilterSpecification?) -> HTTPSTransientBloomFilterSpecification? {
        guard let specification = specification else { return nil }
        return HTTPSTransientBloomFilterSpecification(totalEntries: Int(specification.totalEntries),
                                                      errorRate: specification.errorRate,
                                                      sha256: specification.sha256!)
    }
}
