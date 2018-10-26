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
//    var barLightTintColor: UIColor { get }
//    var barInactiveButtonColor: UIColor { get }
    
    var searchBarBackgroundColor: UIColor { get }
//    var searchBarPlaceholderTextColor: UIColor { get }
    var searchBarTextColor: UIColor { get }
    
    var tableCellBackgrundColor: UIColor { get }
    var tableCellTintColor: UIColor { get }
    var tableCellSeparatorColor: UIColor { get }
}

protocol Themable {
    func decorate(with theme: Theme)
}

extension UIViewController {
    func applyTheme(_ theme: Theme) {
        if let themable = self as? Themable {
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
        navigationController?.navigationBar.barTintColor = theme.barBackgroundColor
        navigationController?.navigationBar.backgroundColor = theme.barBackgroundColor
        
        view.tintColor = theme.barTintColor
        view.backgroundColor = theme.backgroundColor
    }
}
