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
    
    private struct Keys {
        static let hasSeenOnboarding = "com.duckduckgo.tutorials.hasSeenOnboarding"
        static let hasSeenSafariSearchInstructions = "com.duckduckgo.tutorials.hasSeenSafariSearchInstructions"
        static let hasSeenFireTutorial = "com.duckduckgo.tutorials.hasSeenFireTutorial"
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
    
    public var hasSeenSafariSearchInstructions: Bool {
        get {
            return userDefaults().bool(forKey: Keys.hasSeenSafariSearchInstructions, defaultValue: false)
        }
        set(newValue) {
            userDefaults().set(newValue, forKey: Keys.hasSeenSafariSearchInstructions)
        }
    }
    
    public var hasSeenFireTutorial: Bool {
        get {
            return userDefaults().bool(forKey: Keys.hasSeenFireTutorial, defaultValue: false)
        }
        set(newValue) {
            userDefaults().set(newValue, forKey: Keys.hasSeenFireTutorial)
        }
    }
}
