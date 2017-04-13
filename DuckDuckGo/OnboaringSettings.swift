//
//  OnboardingSettings.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 03/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import Core

struct OnboardingSettings {
    
    private let suit = "onboardingSettingsSuit"
    
    private struct Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let instructionsFirstLaunch = "instructionsFirstLaunch"
    }
    
    public var hasSeenOnboarding: Bool {
        get {
            guard let userDefaults = userDefaults() else { return false }
            return userDefaults.bool(forKey: Keys.hasSeenOnboarding, defaultValue: false)
        }
        set(newValue) {
            userDefaults()?.set(newValue, forKey: Keys.hasSeenOnboarding)
        }
    }
    
    public var instructionsFirstLaunch: Bool {
        get {
            guard let userDefaults = userDefaults() else { return true }
            return userDefaults.bool(forKey: Keys.instructionsFirstLaunch, defaultValue: true)
        }
        set(newValue) {
            userDefaults()?.set(newValue, forKey: Keys.instructionsFirstLaunch)
        }
    }
    
    private func userDefaults() -> UserDefaults? {
        return UserDefaults(suiteName: suit)
    }
}
