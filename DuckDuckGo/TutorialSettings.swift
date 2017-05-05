//
//  TutorialSettings.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 03/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import Core

struct TutorialSettings {
    
    private let suit = "onboardingSettingsSuit"
    
    private struct Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let hasSeenSafariSearchInstructions = "hasSeenSafariSearchInstructions"
        static let hasSeenFireTutorial = "hasSeenFireTutorial"
    }
    
    public var hasSeenOnboarding: Bool {
        get {
            guard let userDefaults = userDefaults() else { return true }
            return userDefaults.bool(forKey: Keys.hasSeenOnboarding, defaultValue: false)
        }
        set(newValue) {
            userDefaults()?.set(newValue, forKey: Keys.hasSeenOnboarding)
        }
    }
    
    public var hasSeenSafariSearchInstructions: Bool {
        get {
            guard let userDefaults = userDefaults() else { return true }
            return userDefaults.bool(forKey: Keys.hasSeenSafariSearchInstructions, defaultValue: false)
        }
        set(newValue) {
            userDefaults()?.set(newValue, forKey: Keys.hasSeenSafariSearchInstructions)
        }
    }
    
    public var hasSeenFireTutorial: Bool {
        get {
            guard let userDefaults = userDefaults() else { return true }
            return userDefaults.bool(forKey: Keys.hasSeenFireTutorial, defaultValue: false)
        }
        set(newValue) {
            userDefaults()?.set(newValue, forKey: Keys.hasSeenFireTutorial)
        }
    }
    
    private func userDefaults() -> UserDefaults? {
        return UserDefaults(suiteName: suit)
    }
}
