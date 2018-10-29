//
//  Themable.swift
//  DuckDuckGo
//
//  Created by Bartek on 29/10/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

/// Protocol representing UI element that can be decorated with Theme.
protocol Themable {
    /// Implement to customize based on Theme
    func decorate(with theme: Theme)
}

extension Themable where Self: UIViewController {
    
    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
    }
    
    func decorateNavigationBar(with theme: Theme) {
        navigationController?.navigationBar.barTintColor = theme.barBackgroundColor
        navigationController?.navigationBar.backgroundColor = theme.barBackgroundColor
        navigationController?.navigationBar.tintColor = theme.barTintColor
        
        var titleAttrs = navigationController?.navigationBar.titleTextAttributes ?? [:]
        titleAttrs[NSAttributedString.Key.foregroundColor] = theme.barTitleColor
        navigationController?.navigationBar.titleTextAttributes = titleAttrs
    }
}

/// This extension acts as part of a Theme-change propagation mechanism.
///
/// ThemeManager calls 'applyTheme(with:)' on main window's rootViewController.
/// This call is then propagated to every child/presented ViewController. If view
/// controller implements Themable protocol, 'decorate(with:)' method is also invoked.
extension UIViewController {
    
    /// Call to propagate theme change across related controllers.
    ///
    /// Note: if view controller implements 'Themable' protocol, 'decorate(with:)'
    /// method is called to customise it.
    func applyTheme(_ theme: Theme) {
        if let themable = self as? Themable {
            themable.decorate(with: theme)
        }
        
        decorateNestedControllers(with: theme)
    }
    
    private func decorateNestedControllers(with theme: Theme) {
        for controller in children {
            controller.applyTheme(theme)
        }
        
        if let controller = presentedViewController {
            controller.applyTheme(theme)
        }
    }
}
