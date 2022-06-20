//
//  FeatureFlagger.swift
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

public enum Feature: String {
    case debugMenu
    case autofill
}

public protocol FeatureFlagger {
    func isFeatureOn(_ feature: Feature) -> Bool
}

public protocol FeatureFlaggerInternalUserDecider {
    
    var isInternalUser: Bool { get }
    
    @discardableResult
    func markUserAsInternalIfNeeded(forUrl url: URL?, response: HTTPURLResponse?) -> Bool
}

public class DefaultFeatureFlagger: FeatureFlagger {
    
    public init() { }
    
    public func isFeatureOn(_ feature: Feature) -> Bool {
        switch feature {
        case .debugMenu:
            return isInternalUser
        case .autofill:
            if isInternalUser {
                return true
            } else {
                return false
            }
        }
    }
    
    @UserDefaultsWrapper(key: .featureFlaggingDidVerifyInternalUser, defaultValue: false)
    private var didVerifyInternalUser: Bool
}

extension DefaultFeatureFlagger: FeatureFlaggerInternalUserDecider {
    
    public var isInternalUser: Bool {
        if isDebugBuild {
            return true
        }
        return didVerifyInternalUser
    }
    
    private static let internalUserVerificationURLHost = "login.duckduckgo.com"
    
    @discardableResult
    public func markUserAsInternalIfNeeded(forUrl url: URL?, response: HTTPURLResponse?) -> Bool {
        if isInternalUser { // If we're already an internal user, we don't need to do anything
            return false
        }
        
        if shouldMarkUserAsInternal(forUrl: url, statusCode: response?.statusCode) {
            didVerifyInternalUser = true
            Pixel.fire(pixel: .featureFlaggingInternalUserAuthenticated)
            return true
        }
        return false
    }
    
    func shouldMarkUserAsInternal(forUrl url: URL?, statusCode: Int?) -> Bool {
        if let statusCode = statusCode,
           statusCode == 200,
           let url = url,
           url.host == DefaultFeatureFlagger.internalUserVerificationURLHost {
            
            return true
        }
        return false
    }
}
