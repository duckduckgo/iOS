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

    @IBOutlet var margins: [NSLayoutConstraint]!
    @IBOutlet weak var lightThemeToggle: UISwitch!
    @IBOutlet weak var autocompleteToggle: UISwitch!
    @IBOutlet weak var authenticationToggle: UISwitch!
    @IBOutlet weak var homePageAccessoryText: UILabel!
    @IBOutlet weak var autoClearAccessoryText: UILabel!
    @IBOutlet weak var versionText: UILabel!
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var accessoryLabels: [UILabel]!
    
    weak var homePageSettingsDelegate: HomePageSettingsDelegate?

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureAutoClearCellAccessory()
        configureHomePageCellAccessory()
        migrateFavoritesIfNeeded()
    }
    
    private func migrateFavoritesIfNeeded() {
        // This ensures the user does not loose access to their favorites if they change the home page setting
        if appSettings.homePage != .centerSearchAndFavorites {
            BookmarksManager().migrateFavoritesToBookmarks()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AutoClearSettingsViewController {
            Pixel.fire(pixel: .autoClearSettingsShown)
            return
        }
        
        if let controller = segue.destination as? HomePageSettingsViewController {
            Pixel.fire(pixel: .settingsHomePageShown)
            controller.delegate = homePageSettingsDelegate
            return
        }
        
        if let navController = segue.destination as? UINavigationController, navController.topViewController is FeedbackViewController {
            if UIDevice.current.userInterfaceIdiom == .pad {
                segue.destination.modalPresentationStyle = .formSheet
            }
        }
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
    
    private func configureAutoClearCellAccessory() {
        if AutoClearSettingsModel(settings: appSettings) != nil {
            autoClearAccessoryText.text = UserText.autoClearAccessoryOn
        } else {
            autoClearAccessoryText.text = UserText.autoClearAccessoryOff
        }
    }
    
    private func configureHomePageCellAccessory() {

        switch appSettings.homePage {
            
        case .simple:
            homePageAccessoryText.text = UserText.homePageSimple
            
        case .centerSearch:
            homePageAccessoryText.text = UserText.homePageCenterSearch

        case .centerSearchAndFavorites:
            homePageAccessoryText.text = UserText.homePageCenterSearchAndFavorites

        }
        
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
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
        
        if cell.accessoryType == .disclosureIndicator {
            let accesoryImage = UIImageView(image: UIImage(named: "DisclosureIndicator"))
            accesoryImage.frame = CGRect(x: 0, y: 0, width: 8, height: 13)
            accesoryImage.tintColor = theme.tableCellAccessoryColor
            cell.accessoryView = accesoryImage
        }
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
            label.textColor = theme.tableCellTextColor
        }
        
        for label in accessoryLabels {
            label.textColor = theme.tableCellAccessoryTextColor
        }
        
        versionText.textColor = theme.tableCellTextColor
        
        lightThemeToggle.onTintColor = theme.buttonTintColor
        autocompleteToggle.onTintColor = theme.buttonTintColor
        authenticationToggle.onTintColor = theme.buttonTintColor
        
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
