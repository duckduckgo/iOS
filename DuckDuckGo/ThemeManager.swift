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

protocol RootControllersProvider {
    var rootControllers: [UIViewController] { get }
}

class ThemeManager {
    
    class UIApplicationRootControllersProvider: RootControllersProvider {
        var rootControllers: [UIViewController] {
            return UIApplication.shared.windows.compactMap { $0.rootViewController }
        }
    }
    
    enum ImageSet {
        case light
        case dark
    }
    
    public static let shared = ThemeManager()

    private var appSettings: AppSettings
    
    var rootControllersProvider: RootControllersProvider
    private(set) var currentTheme: Theme {
        didSet {
            for controller in rootControllersProvider.rootControllers {
                controller.applyTheme(currentTheme)
            }
        }
    }
    
    private static func makeTheme(name: ThemeName) -> Theme {
        switch name {
        case .systemDefault:
            if #available(iOS 13.0, *) {
                return obtainSystemTheme()
            } else {
                return DarkTheme()
            }
        case .dark:
            return DarkTheme()
        case .light:
            return LightTheme()

        }
    }
    
    @available(iOS 13.0, *)
    private static func obtainSystemTheme() -> Theme {
        switch UIScreen.main.traitCollection.userInterfaceStyle {
        case .dark:
            return DarkTheme()
        case .light:
            return LightTheme()
        default:
            return DarkTheme()
        }
    }
    
    init(settings: AppSettings = AppUserDefaults(),
         rootProvider: RootControllersProvider = UIApplicationRootControllersProvider()) {
        
        appSettings = settings
        currentTheme = ThemeManager.makeTheme(name: settings.currentThemeName)
        rootControllersProvider = rootProvider
    }
    
    public func enableTheme(with name: ThemeName) {
        appSettings.currentThemeName = name
        currentTheme = ThemeManager.makeTheme(name: name)
    }
    
    @available(iOS 13.0, *)
    public func refreshSystemTheme() {
        guard appSettings.currentThemeName == .systemDefault else { return }
        
        let systemTheme = type(of: self).obtainSystemTheme()
        
        if systemTheme.name != currentTheme.name {
            currentTheme = systemTheme
        }
    }
    
}
