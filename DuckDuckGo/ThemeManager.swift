//
//  ThemeManager.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
import UIKit
import Core

class ThemeManager {
    
    enum ImageSet {
        case light
        case dark
    }
    
    public static let shared = ThemeManager()

    private var appSettings: AppSettings
    
    var rootController: UIViewController?
    private(set) var currentTheme: Theme {
        didSet {
            rootController?.applyTheme(currentTheme)
        }
    }
    
    private static func makeTheme(name: ThemeName) -> Theme {
        switch name {
        case .light:
            return LightTheme()
        case .dark:
            return DarkTheme()
        }
    }
    
    init(variantManager: VariantManager = DefaultVariantManager(),
         settings: AppSettings = AppUserDefaults()) {
        variantManager.assignVariantIfNeeded()
        
        // Set default theme in case user participates in experiment
        if let variant = variantManager.currentVariant {
            if variant.features.contains(.lightThemeByDefault) {
                settings.setInitialThemeNameIfNeeded(name: .light)
            } else if variant.features.contains(.darkThemeByDefault) {
                settings.setInitialThemeNameIfNeeded(name: .dark)
            }
        }
        
        appSettings = settings
        currentTheme = ThemeManager.makeTheme(name: settings.currentThemeName)
    }
    
    public func enableTheme(with name: ThemeName) {
        appSettings.currentThemeName = name
        currentTheme = ThemeManager.makeTheme(name: name)
    }
}
