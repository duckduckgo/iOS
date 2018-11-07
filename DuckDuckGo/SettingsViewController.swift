//
//  SettingsViewController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import MessageUI
import Core
import Device

class SettingsViewController: UITableViewController {
    
    private struct IndexPaths {
        static let lightThemeOptionCell = IndexPath(row: 0, section: 0)
    }

    @IBOutlet var margins: [NSLayoutConstraint]!
    @IBOutlet weak var lightThemeToggle: UISwitch!
    @IBOutlet weak var autocompleteToggle: UISwitch!
    @IBOutlet weak var authenticationToggle: UISwitch!
    @IBOutlet weak var versionText: UILabel!
    
    @IBOutlet var labels: [UILabel]!

    private lazy var versionProvider: AppVersion = AppVersion()
    fileprivate lazy var privacyStore = PrivacyUserDefaults()
    fileprivate lazy var appSettings = AppDependencyProvider.shared.appSettings
    fileprivate lazy var variantManager = AppDependencyProvider.shared.variantManager

    static func loadFromStoryboard() -> UIViewController {
        return UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController()!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMargins()
        configureLightThemeToggle()
        configureDisableAutocompleteToggle()
        configureSecurityToggles()
        configureVersionText()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }

    private func configureMargins() {
        guard #available(iOS 11, *) else { return }
        for margin in margins {
            margin.constant = 0
        }
    }
    
    private func configureLightThemeToggle() {
        lightThemeToggle.isOn = appSettings.currentThemeName == .light
    }

    private func configureDisableAutocompleteToggle() {
        autocompleteToggle.isOn = appSettings.autocomplete
    }

    private func configureSecurityToggles() {
        authenticationToggle.isOn = privacyStore.authenticationEnabled
    }

    private func configureVersionText() {
        versionText.text = versionProvider.localized
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPaths.lightThemeOptionCell {
            // Show light theme toggle when user participates in experiment
            guard let currentVariant = variantManager.currentVariant,
                currentVariant.features.contains(.themeToggle) else {
                return 0
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            let theme = ThemeManager.shared.currentTheme
            view.textLabel?.textColor = theme.tableHeaderTextColor
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            let theme = ThemeManager.shared.currentTheme
            view.textLabel?.textColor = theme.tableHeaderTextColor
        }
    }

    @IBAction func onAuthenticationToggled(_ sender: UISwitch) {
        privacyStore.authenticationEnabled = sender.isOn
    }
    
    @IBAction func onLightThemeToggled(_ sender: UISwitch) {
        let pixelName = sender.isOn ? PixelName.settingsThemeToggledLight : PixelName.settingsThemeToggledDark
        Pixel.fire(pixel: pixelName)
        ThemeManager.shared.enableTheme(with: sender.isOn ? .light : .dark)
    }

    @IBAction func onDonePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onAutocompleteToggled(_ sender: UISwitch) {
        appSettings.autocomplete = sender.isOn
    }
}

extension SettingsViewController: Themable {
    
    func decorate(with theme: Theme) {
        
        for label in labels {
            label.textColor = theme.tableCellTintColor
        }
        
        versionText.textColor = theme.tableCellTintColor
        
        lightThemeToggle.onTintColor = theme.toggleSwitchColor
        autocompleteToggle.onTintColor = theme.toggleSwitchColor
        authenticationToggle.onTintColor = theme.toggleSwitchColor
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        if let navigationController = self.navigationController {
            UIView.transition(with: navigationController.navigationBar,
                              duration: 0.2,
                              options: .transitionCrossDissolve, animations: {
                                self.decorateNavigationBar(with: theme)
            }, completion: nil)
        }
        
        UIView.transition(with: view,
                          duration: 0.2,
                          options: .transitionCrossDissolve, animations: {
                            self.tableView.reloadData()
        }, completion: nil)
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

extension MFMailComposeViewController {
    static func create() -> MFMailComposeViewController? {
        return MFMailComposeViewController()
    }
}
