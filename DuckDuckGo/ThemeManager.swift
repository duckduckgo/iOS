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
    
    init(variantManager: VariantManager = DefaultVariantManager(),
         settings: AppSettings = AppUserDefaults()) {
        variantManager.assignVariantIfNeeded()
        
        // Set default theme in case user participates in experiment
        if let variant = variantManager.currentVariant {
            if variant.features.contains(.lightThemeByDefault) {
                settings.setInitialLightThemeValueIfNeeded(value: true)
            } else if variant.features.contains(.darkThemeByDefault) {
                settings.setInitialLightThemeValueIfNeeded(value: false)
            }
        }
        
        appSettings = settings
        if settings.lightTheme {
            currentTheme = LightTheme()
        } else {
            currentTheme = DarkTheme()
        }
    }
    
    public func enableLightTheme(_ lightThemeEnabled: Bool) {
        appSettings.lightTheme = lightThemeEnabled
        
        if lightThemeEnabled {
            currentTheme = LightTheme()
        } else {
            currentTheme = DarkTheme()
        }
    }
}
