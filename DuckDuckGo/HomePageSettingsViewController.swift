//
//  HomePageSettingsDelegate.swift
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

protocol HomePageSettingsDelegate: NSObjectProtocol {
    
    func homePageChanged(to config: HomePageConfiguration.ConfigName)
    
}

class HomePageSettingsViewController: UITableViewController {
    
    @IBOutlet var labels: [UILabel]!

    weak var delegate: HomePageSettingsDelegate?
    
    private lazy var appSettings = AppDependencyProvider.shared.appSettings

    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
 
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
        
        // Checkmark color
        cell.tintColor = theme.buttonTintColor

        if indexPath.section == 0 {
            cell.accessoryType = indexPath.row == appSettings.homePageConfig.rawValue ? .checkmark : .none
        } else {

            switch indexPath.row {
            case 0:
                cell.accessoryType = appSettings.homePageKeyboardOnAppLaunch ? .checkmark : .none

            case 1:
                cell.accessoryType = appSettings.homePageKeyboardOnNewTab ? .checkmark : .none

            case 2:
                cell.accessoryType = appSettings.homePageKeyboardAfterFireButton ? .checkmark : .none

            default: break

            }

        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            updateHomePageSetting(row: indexPath.row)
        } else {
            updateKeyboardSetting(row: indexPath.row)
        }

        tableView.reloadData()
    }

    private func updateKeyboardSetting(row: Int) {
        switch row {
        case 0:
            appSettings.homePageKeyboardOnAppLaunch = !appSettings.homePageKeyboardOnAppLaunch

        case 1:
            appSettings.homePageKeyboardOnNewTab = !appSettings.homePageKeyboardOnNewTab

        case 2:
            appSettings.homePageKeyboardAfterFireButton = !appSettings.homePageKeyboardAfterFireButton

        default: break
        }
    }

    private func updateHomePageSetting(row: Int) {
        guard appSettings.homePageConfig.rawValue != row else { return }
        let config = HomePageConfiguration.ConfigName(rawValue: row)!

        switch config {
        case .simple:
            Pixel.fire(pixel: .settingsHomePageSimple)

        case .centerSearch:
            Pixel.fire(pixel: .settingsHomePageCenterSearch)

        case .centerSearchAndFavorites:
            Pixel.fire(pixel: .settingsHomePageCenterSearchAndFavorites)

        case .simpleAndFavorites:
            Pixel.fire(pixel: .settingsHomePageSimpleAndFavorites)

        }

        appSettings.homePageConfig = config
        delegate?.homePageChanged(to: config)
    }
    
}

extension HomePageSettingsViewController: Themable {

    func decorate(with theme: Theme) {
        
        for label in labels {
            label.textColor = theme.tableCellTextColor
        }
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        tableView.reloadData()
    }
}
