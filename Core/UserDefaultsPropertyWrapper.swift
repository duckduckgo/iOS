//
//  UserDefaultsPropertyWrapper.swift
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

// Inspired by https://swiftsenpai.com/swift/create-the-perfect-userdefaults-wrapper-using-property-wrapper/

// enums are not supported on iOS 12 due to a bug in JSONEncoder, so just use primitive types or NSCodables

@propertyWrapper
public struct UserDefaultsWrapper<T> {

    public enum Key: String, CaseIterable {

        case layout = "com.duckduckgo.ios.home.layout"
        case favorites = "com.duckduckgo.ios.home.favorites"
        case keyboardOnNewTab = "com.duckduckgo.ios.keyboard.newtab"
        case keyboardOnAppLaunch = "com.duckduckgo.ios.keyboard.applaunch"
        
        case gridViewEnabled = "com.duckduckgo.ios.tabs.grid"
        case gridViewSeen = "com.duckduckgo.ios.tabs.seen"
        
        case preserveLoginsAllowedDomains = "com.duckduckgo.ios.PreserveLogins.userDecision.allowedDomains2"
        case preserveLoginsDetectionEnabled = "com.duckduckgo.ios.PreserveLogins.detectionEnabled"
        case preserveLoginsLegacyAllowedDomains = "com.duckduckgo.ios.PreserveLogins.userDecision.allowedDomains"

        case daxIsDismissed = "com.duckduckgo.ios.daxOnboardingIsDismissed"
        case daxHomeScreenMessagesSeen = "com.duckduckgo.ios.daxOnboardingHomeScreenMessagesSeen"
        case daxBrowsingAfterSearchShown = "com.duckduckgo.ios.daxOnboardingBrowsingAfterSearchShown"
        case daxBrowsingWithTrackersShown = "com.duckduckgo.ios.daxOnboardingBrowsingWithTrackersShown"
        case daxBrowsingWithoutTrackersShown = "com.duckduckgo.ios.daxOnboardingBrowsingWithoutTrackersShown"
        case daxBrowsingMajorTrackingSiteShown = "com.duckduckgo.ios.daxOnboardingBrowsingMajorTrackingSiteShown"
        case daxBrowsingOwnedByMajorTrackingSiteShown = "com.duckduckgo.ios.daxOnboardingBrowsingOwnedByMajorTrackingSiteShown"
        
        case legacyCovidInfo = "com.duckduckgo.ios.home.covidInfo"
    }

    private let key: Key
    private let defaultValue: T

    public init(key: Key, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key.rawValue) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key.rawValue)
        }
    }
}
