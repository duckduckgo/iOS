//
//  ThemeTmp.swift
//  DuckDuckGo
//
//  Created by Bartek on 20/10/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

protocol Theme {
    
    var currentImageSet: ThemeManager.ImageSet { get }
    var statusBarStyle: UIStatusBarStyle { get }
    
    var backgroundColor: UIColor { get }
    
    var barBackgroundColor: UIColor { get }
    var barTintColor: UIColor { get }
    var barTitleColor: UIColor { get }
    
    var searchBarBackgroundColor: UIColor { get }
    var searchBarTextColor: UIColor { get }
    
    var tableCellBackgrundColor: UIColor { get }
    var tableCellTintColor: UIColor { get }
    var tableCellSeparatorColor: UIColor { get }
    var tableHeaderTextColor: UIColor { get }
    
    var toggleSwitchColor: UIColor? { get }
    
    var homeRowPrimaryTextColor: UIColor { get }
    var homeRowSecondaryTextColor: UIColor { get }
    var homeRowBackgroundColor: UIColor { get }
    
    var aboutScreenTextColor: UIColor { get }
    var aboutScreenButtonColor: UIColor { get }
}

protocol Themable {
    /// Implement to customize view based on Theme
    func decorate(with theme: Theme)
}

extension UIViewController {
    func applyTheme(_ theme: Theme) {
        if let themable = self as? Themable {
            navigationController?.navigationBar.barTintColor = theme.barBackgroundColor
            navigationController?.navigationBar.backgroundColor = theme.barBackgroundColor
            navigationController?.navigationBar.tintColor = theme.barTintColor
            
            var titleAttrs = navigationController?.navigationBar.titleTextAttributes ?? [:]
            titleAttrs[NSAttributedString.Key.foregroundColor] = theme.barTitleColor
            navigationController?.navigationBar.titleTextAttributes = titleAttrs
            
            themable.decorate(with: theme)
        }
        
        decorateNestedControllers(with: theme)
    }
    
    func decorateNestedControllers(with theme: Theme) {
        for controller in children {
            controller.applyTheme(theme)
        }
        
        if let controller = presentedViewController {
            controller.applyTheme(theme)
        }
    }
}

extension Themable where Self: UIViewController {
    
    func decorate(with theme: Theme) {
        
    }
}
