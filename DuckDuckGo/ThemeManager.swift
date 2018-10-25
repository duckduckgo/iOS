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
    
    static var defaultTheme = DarkTheme()
    
    private var rootController: UIViewController
    var currentTheme: Theme {
        didSet {
            rootController.applyTheme(currentTheme)
        }
    }
    
    init(rootViewController: UIViewController) {
        //TODO: load theme from Settings
        
        rootController = rootViewController
        currentTheme = type(of: self).defaultTheme
    }
}

// MARK: -
extension ThemeManager {
    
    static var cycleIteration = 0
    
    /// Run to enable cycling through themes
    func cycle() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if type(of: self).cycleIteration % 2 == 1 {
                self.currentTheme = DarkTheme()
            } else {
                self.currentTheme = LightTheme()
            }
            type(of: self).cycleIteration += 1
            
            self.cycle()
        }
    }
}
