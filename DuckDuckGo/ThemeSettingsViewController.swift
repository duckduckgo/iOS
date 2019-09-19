//
//  ThemeSettingsViewController.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

class ThemeSettingsViewController: UITableViewController {
    
    private lazy var appSettings = AppDependencyProvider.shared.appSettings

    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if #available(iOS 13.0, *) {
            return 3
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ThemeItemCell", for: indexPath)
    }
 
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ThemeItemCell else {
            fatalError("Expected ThemeItemCell")
        }
        
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
        
        // Checkmark color
        cell.tintColor = theme.buttonTintColor
        cell.themeNameLabel.textColor = theme.tableCellTextColor
        
        let themeName = themeForRow(at: indexPath)
        switch themeName {
        case .systemDefault:
            cell.themeName = UserText.themeNameDefault
        case .light:
            cell.themeName = UserText.themeNameLight
        case .dark:
            cell.themeName = UserText.themeNameDark
        }
        
        cell.accessoryType = themeName == appSettings.currentThemeName ? .checkmark : .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let theme = themeForRow(at: indexPath)
        appSettings.currentThemeName = theme
        
        tableView.reloadData()
        
//        let pixelName = sender.isOn ? PixelName.settingsThemeToggledLight : PixelName.settingsThemeToggledDark
//        Pixel.fire(pixel: pixelName)
        ThemeManager.shared.enableTheme(with: theme)
    }
    
    private func themeForRow(at indexPath: IndexPath) -> ThemeName {
        let index: Int
        if #available(iOS 13.0, *) {
            index = indexPath.row
        } else {
            index = indexPath.row + 1
        }
        
        switch index {
        case 0:
            return .systemDefault
        case 1:
            return .light
        default:
            return .dark
        }
    }
}

class ThemeItemCell: UITableViewCell {

    @IBOutlet weak var themeNameLabel: UILabel!

    var themeName: String? {
        get {
            return themeNameLabel.text
        }
        set {
            themeNameLabel.text = newValue
        }
    }
}

extension ThemeSettingsViewController: Themable {

    func decorate(with theme: Theme) {
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
    }
}
