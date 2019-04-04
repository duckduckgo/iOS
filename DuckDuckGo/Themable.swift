//
//  Themable.swift
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
        navigationController?.navigationBar.tintColor = theme.navigationBarTintColor
        
        var titleAttrs = navigationController?.navigationBar.titleTextAttributes ?? [:]
        titleAttrs[NSAttributedString.Key.foregroundColor] = theme.navigationBarTitleColor
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
