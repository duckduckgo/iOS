//
//  PrivacyConfiguration.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

public struct PrivacyConfiguration: Codable {
    public typealias FeatureName = String
    public typealias UnprotectedList = [ExceptionEntry]
    
    public let features: [FeatureName: PrivacyFeature]
    public let unprotectedTemporary: UnprotectedList
    
    public init(features: [String: PrivacyFeature], unprotectedTemporary: [ExceptionEntry]) {
        self.features = features
        self.unprotectedTemporary = unprotectedTemporary
    }
    
    public var tempUnprotectedDomains: [String] {
        return unprotectedTemporary.map { $0.domain }
    }
    
    enum CodingKeys: String, CodingKey {
        case features
        case unprotectedTemporary
    }
}

public struct PrivacyFeature: Codable {
    public typealias FeatureState = String
    public typealias ExceptionList = [ExceptionEntry]
    public typealias FeatureSettings = [String: String]
    
    public let state: FeatureState
    public let exceptions: ExceptionList
    
    public init(state: String, exceptions: [ExceptionEntry]) {
        self.state = state
        self.exceptions = exceptions
    }
    
    enum CodingKeys: String, CodingKey {
        case state
        case exceptions
    }
}

public struct ExceptionEntry: Codable {
    public typealias ExcludedDomain = String
    public typealias ExclusionReason = String
    
    public let domain: ExcludedDomain
    public let reason: ExclusionReason?
    
    public init(domain: String, reason: String?) {
        self.domain = domain
        self.reason = reason
    }
    
    enum CodingKeys: String, CodingKey {
        case domain
        case reason
    }
}
