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

struct TutorialSettings {
    
    private struct Keys {
        // Set the build number of the last build that didn't force them to appear to force them to appear.
        static let lastBuildWithoutForcePop = 1
        static let hasSeenOnboarding = "com.duckduckgo.tutorials.hasSeenOnboarding.\(lastBuildWithoutForcePop)"
    }
    
    private func userDefaults() -> UserDefaults {
        return UserDefaults.standard
    }
    
    public var hasSeenOnboarding: Bool {
        get {
            return userDefaults().bool(forKey: Keys.hasSeenOnboarding, defaultValue: false)
        }
        set(newValue) {
            userDefaults().set(newValue, forKey: Keys.hasSeenOnboarding)
        }
    }
}
