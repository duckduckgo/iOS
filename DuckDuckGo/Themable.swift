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

extension UIViewController {

    func decorateNavigationBar(with theme: Theme = ThemeManager.shared.currentTheme) {
        navigationController?.navigationBar.barTintColor = theme.barBackgroundColor
        navigationController?.navigationBar.tintColor = theme.navigationBarTintColor
        
        var titleAttrs = navigationController?.navigationBar.titleTextAttributes ?? [:]
        titleAttrs[NSAttributedString.Key.foregroundColor] = theme.navigationBarTitleColor
        navigationController?.navigationBar.titleTextAttributes = titleAttrs
        
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = theme.backgroundColor
        appearance.titleTextAttributes = titleAttrs

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func decorateToolbar(with theme: Theme = ThemeManager.shared.currentTheme) {
        navigationController?.toolbar.barTintColor = theme.barBackgroundColor
        navigationController?.toolbar.backgroundColor = theme.barBackgroundColor
        navigationController?.toolbar.tintColor = theme.barTintColor
        
        let appearance = navigationController?.toolbar.standardAppearance
        navigationController?.toolbar.scrollEdgeAppearance = appearance
    }
}
