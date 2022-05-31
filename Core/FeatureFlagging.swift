//
//  FeatureFlagging.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

enum Feature: String {
    case debugMenu
}

protocol FeatureFlagging {
    var isInternalUser: Bool { get }
    func isFeatureOn(_ feature: Feature) -> Bool
}

class DefaultFeatureFlagging: FeatureFlagging {
    
    var isInternalUser: Bool {
        if isDebugBuild {
            return true
        }
        // TODO
        return false
    }
    
    func isFeatureOn(_ feature: Feature) -> Bool {
        switch feature {
        case .debugMenu:
            return isInternalUser
        }
    }
    
    let internalUserVerificationURLHost = "login.duckduckgo.com"
    
    @UserDefaultsWrapper(key: .featureFlaggingDidVerifyInternalUser, defaultValue: false)
    private var didVerifyInternalUser: Bool
    
    @discardableResult
    func markUserAsInternalIfNeeded(forUrl url: URL?, response: HTTPURLResponse?) -> Bool {
        if isInternalUser { // If we're already an internal user, we don't need to do anything
            //return true
        }
        
        guard let response = response,
                response.statusCode == 200,
                let url = url,
                url.host == internalUserVerificationURLHost else { return false }
        
        didVerifyInternalUser = true
        return true
    }
}
