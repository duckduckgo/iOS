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

    @IBOutlet weak var favoritesToggle: UISwitch!
    @IBOutlet weak var privacyStatsToggle: UISwitch!
    @IBOutlet weak var onAppLaunchToggle: UISwitch!
    @IBOutlet weak var onNewTabToggle: UISwitch!
    @IBOutlet weak var afterFireButtonToggle: UISwitch!

    weak var delegate: HomePageSettingsDelegate?
    
    private lazy var appSettings = AppDependencyProvider.shared.appSettings

    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme(ThemeManager.shared.currentTheme)
        updateTogglesFromSettings()
    }
 
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
        
        // Checkmark color
        cell.tintColor = theme.buttonTintColor

        if indexPath.section == 0 {
            updateConfigAccessory(onCell: cell, forRow: indexPath.row)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            updateHomePageSetting(row: indexPath.row)
        }

        tableView.reloadData()
        delegate?.homePageChanged(to: appSettings.homePageConfig)
    }

    @IBAction func toggleUpdated() {
        updateSettingsFromToggles()
        delegate?.homePageChanged(to: appSettings.homePageConfig)
    }

    private func updateSettingsFromToggles() {

        appSettings.homePageFeatureFavorites = favoritesToggle.isOn
        appSettings.homePageFeaturePrivacyStats = privacyStatsToggle.isOn

        appSettings.homePageKeyboardOnAppLaunch = onAppLaunchToggle.isOn
        appSettings.homePageKeyboardOnNewTab = onNewTabToggle.isOn
        appSettings.homePageKeyboardAfterFireButton = afterFireButtonToggle.isOn

    }

    private func updateTogglesFromSettings() {

        favoritesToggle.isOn = appSettings.homePageFeatureFavorites
        privacyStatsToggle.isOn = appSettings.homePageFeaturePrivacyStats

        onAppLaunchToggle.isOn = appSettings.homePageKeyboardOnAppLaunch
        onNewTabToggle.isOn = appSettings.homePageKeyboardOnNewTab
        afterFireButtonToggle.isOn = appSettings.homePageKeyboardAfterFireButton

    }

    private func updateConfigAccessory(onCell cell: UITableViewCell, forRow row: Int) {

        switch appSettings.homePageConfig {

        case .simple, .simpleAndFavorites:
            cell.accessoryType = row == 0 ? .checkmark : .none

        case .centerSearch, .centerSearchAndFavorites:
            cell.accessoryType = row == 1 ? .checkmark : .none

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

        labels.forEach { $0.textColor = theme.tableCellTextColor }

        [ favoritesToggle, privacyStatsToggle, onAppLaunchToggle, onNewTabToggle, afterFireButtonToggle ].forEach {
            $0?.onTintColor = theme.buttonTintColor
        }

        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        tableView.reloadData()
    }
}
