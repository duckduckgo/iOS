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

        switch indexPath.section {
        case 0:
            updateConfigAccessory(onCell: cell, forRow: indexPath.row)

        case 1:
            updateFeaturesAccessory(onCell: cell, forRow: indexPath.row)

        case 2:
            updateKeyboardAccessory(onCell: cell, forRow: indexPath.row)

        default: break
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case 0:
            updateHomePageSetting(row: indexPath.row)

        case 1:
            updateFeatureSetting(row: indexPath.row)

        case 2:
            updateKeyboardSetting(row: indexPath.row)

        default: break
        }

        tableView.reloadData()
        delegate?.homePageChanged(to: appSettings.homePageConfig)
    }

    private func updateConfigAccessory(onCell cell: UITableViewCell, forRow row: Int) {

        switch appSettings.homePageConfig {

        case .simple, .simpleAndFavorites:
            cell.accessoryType = row == 0 ? .checkmark : .none

        case .centerSearch, .centerSearchAndFavorites:
            cell.accessoryType = row == 1 ? .checkmark : .none

        }

    }

    private func updateFeaturesAccessory(onCell cell: UITableViewCell, forRow row: Int) {
        switch row {
        case 0:
            cell.accessoryType = appSettings.homePageFeatureFavorites ? .checkmark : .none

        case 1:
            cell.accessoryType = appSettings.homePageFeaturePrivacyStats ? .checkmark : .none

        default: break
        }
    }

    private func updateKeyboardAccessory(onCell cell: UITableViewCell, forRow row: Int) {
        switch row {
        case 0:
            cell.accessoryType = appSettings.homePageKeyboardOnAppLaunch ? .checkmark : .none

        case 1:
            cell.accessoryType = appSettings.homePageKeyboardOnNewTab ? .checkmark : .none

        case 2:
            cell.accessoryType = appSettings.homePageKeyboardAfterFireButton ? .checkmark : .none
        default: break
        }

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

    private func updateFeatureSetting(row: Int) {
        switch row {
        case 0:
            appSettings.homePageFeatureFavorites = !appSettings.homePageFeatureFavorites

        case 1:
            appSettings.homePageFeaturePrivacyStats = !appSettings.homePageFeaturePrivacyStats

        default: break
        }
    }

    private func updateHomePageSetting(row: Int) {
        switch row {
        case 0:
            appSettings.homePageConfig = .simple

        case 1:
            appSettings.homePageConfig = .centerSearch

        default: break
        }
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
