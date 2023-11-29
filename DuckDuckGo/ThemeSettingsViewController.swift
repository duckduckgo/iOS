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
    
    private typealias ThemeEntry = (themeName: ThemeName, displayName: String)
    
    private lazy var appSettings = AppDependencyProvider.shared.appSettings
    
    private let previousTheme = AppDependencyProvider.shared.appSettings.currentThemeName
    
    private lazy var availableThemes: [ThemeEntry] = {
        return [(ThemeName.systemDefault, UserText.themeNameDefault),
                (ThemeName.light, UserText.themeNameLight),
                (ThemeName.dark, UserText.themeNameDark)]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableThemes.count
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
        
        // Checkmark color
        cell.tintColor = theme.buttonTintColor
        cell.themeNameLabel.textColor = theme.tableCellTextColor
        
        cell.themeName = availableThemes[indexPath.row].displayName

        let themeName = availableThemes[indexPath.row].themeName
        cell.accessoryType = themeName == appSettings.currentThemeName ? .checkmark : .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let theme = availableThemes[indexPath.row].themeName
        appSettings.currentThemeName = theme

        ThemeManager.shared.enableTheme(with: theme)

        ThemeManager.shared.updateUserInterfaceStyle()
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
        
        tableView.reloadData()
    }
}
