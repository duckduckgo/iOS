//
//  ThemeManager.swift
//  DuckDuckGo
//
//  Created by Bartek on 25/10/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

class ThemeManager {
    
    enum ImageSet {
        case light
        case dark
    }
    
    public static let shared = ThemeManager()

    private let appSettings = AppUserDefaults()
    
    var rootController: UIViewController?
    var currentTheme: Theme {
        didSet {
            rootController?.applyTheme(currentTheme)
        }
    }
    
    init() {
        isLightThemeEnabled = appSettings.lightTheme
        if isLightThemeEnabled {
            currentTheme = LightTheme()
        } else {
            currentTheme = DarkTheme()
        }
        // Uncomment to enable automatic theme cycling for testing
//        cycle()
    }
    
    public var isLightThemeEnabled: Bool {
        didSet {
            appSettings.lightTheme = isLightThemeEnabled
            
            if isLightThemeEnabled {
                currentTheme = LightTheme()
            } else {
                currentTheme = DarkTheme()
            }
        }
    }
}

// MARK: -
extension ThemeManager {
    
    static var cycleIteration = 0
    
    /// Run to enable cycling through themes
    func cycle(seconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            if type(of: self).cycleIteration % 2 == 1 {
                self.currentTheme = DarkTheme()
            } else {
                self.currentTheme = LightTheme()
            }
            type(of: self).cycleIteration += 1
            
            self.cycle(seconds: seconds)
        }
    }
}
