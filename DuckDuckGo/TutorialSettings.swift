//
//  TutorialSettings.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import Core

protocol TutorialSettings: AnyObject {

    var lastVersionSeen: Int { get }
    var hasSeenOnboarding: Bool { get set }

}

final class DefaultTutorialSettings: TutorialSettings {

    private struct Constants {
        // Set the build number of the last build that didn't force them to appear to force them to appear.
        static let onboardingVersion = 1
    }

    private struct Keys {
        static let lastVersionSeen = "com.duckduckgo.tutorials.lastVersionSeen"
        static let hasSeenOnboarding = "com.duckduckgo.tutorials.hasSeenOnboarding"
    }

    private func userDefaults() -> UserDefaults {
        return UserDefaults.app
    }

    public var lastVersionSeen: Int {
        return userDefaults().integer(forKey: Keys.lastVersionSeen)
    }

    public var hasSeenOnboarding: Bool {
        get {
            if Constants.onboardingVersion > lastVersionSeen {
                return false
            }
            return userDefaults().bool(forKey: Keys.hasSeenOnboarding, defaultValue: false)
        }
        set(newValue) {
            userDefaults().set(Constants.onboardingVersion, forKey: Keys.lastVersionSeen)
            userDefaults().set(newValue, forKey: Keys.hasSeenOnboarding)
        }
    }

}
