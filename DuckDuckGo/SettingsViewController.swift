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

class SettingsViewController: UITableViewController {

    @IBOutlet weak var defaultBrowserCell: UITableViewCell!
    @IBOutlet weak var themeAccessoryText: UILabel!
    @IBOutlet weak var appIconCell: UITableViewCell!
    @IBOutlet weak var appIconImageView: UIImageView!
    @IBOutlet weak var autocompleteToggle: UISwitch!
    @IBOutlet weak var authenticationToggle: UISwitch!
    @IBOutlet weak var autoClearAccessoryText: UILabel!
    @IBOutlet weak var versionText: UILabel!
    @IBOutlet weak var openUniversalLinksToggle: UISwitch!
    @IBOutlet weak var longPressPreviewsToggle: UISwitch!
    @IBOutlet weak var rememberLoginsCell: UITableViewCell!
    @IBOutlet weak var rememberLoginsAccessoryText: UILabel!
    @IBOutlet weak var doNotSellCell: UITableViewCell!
    @IBOutlet weak var doNotSellAccessoryText: UILabel!
    @IBOutlet weak var longPressCell: UITableViewCell!
    @IBOutlet weak var versionCell: UITableViewCell!

    @IBOutlet var labels: [UILabel]!
    @IBOutlet var accessoryLabels: [UILabel]!
    
    private let defaultBroswerSectionIndex = 0
    
    private lazy var versionProvider: AppVersion = AppVersion.shared
    fileprivate lazy var privacyStore = PrivacyUserDefaults()
    fileprivate lazy var appSettings = AppDependencyProvider.shared.appSettings
    fileprivate lazy var variantManager = AppDependencyProvider.shared.variantManager

    private static var shouldShowDefaultBrowserSection: Bool {
        if #available(iOS 14, *) {
            return true
        } else {
            return false
        }
    }
    
    static func loadFromStoryboard() -> UIViewController {
        return UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController()!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureVersionCell()
        configureDefaultBroswerCell()
        configureThemeCellAccessory()
        configureDisableAutocompleteToggle()
        configureSecurityToggles()
        configureVersionText()
        configureUniversalLinksToggle()
        configureLinkPreviewsToggle()
        configureRememberLogins()
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureAutoClearCellAccessory()
        configureRememberLogins()
        configureDoNotSell()
        configureIconViews()
        
        // Make sure muliline labels are correctly presented
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AutoClearSettingsViewController {
            Pixel.fire(pixel: .autoClearSettingsShown)
            return
        }
        
        if segue.destination is ThemeSettingsViewController {
            Pixel.fire(pixel: .settingsThemeShown)
            return
        }

        if segue.destination is AppIconSettingsViewController {
            Pixel.fire(pixel: .settingsAppIconShown)
            return
        }
 
        if segue.destination is KeyboardSettingsViewController {
            Pixel.fire(pixel: .settingsKeyboardShown)
            return
        }

        if segue.destination is UnprotectedSitesViewController {
            Pixel.fire(pixel: .settingsUnprotectedSites)
            return
        }
        
        if segue.destination is HomeRowInstructionsViewController {
            Pixel.fire(pixel: .settingsHomeRowInstructionsRequested)
            return
        }
        
        if segue.destination is DoNotSellSettingsViewController {
            Pixel.fire(pixel: .settingsDoNotSellShown)
            return
        }
                
        if let navController = segue.destination as? UINavigationController, navController.topViewController is FeedbackViewController {
            if UIDevice.current.userInterfaceIdiom == .pad {
                segue.destination.modalPresentationStyle = .formSheet
            }
        }
    }

    private func configureVersionCell() {
        versionCell.isUserInteractionEnabled = isDebugBuild
    }

    private func configureDefaultBroswerCell() {
        defaultBrowserCell.isHidden = !SettingsViewController.shouldShowDefaultBrowserSection
    }

    private func configureThemeCellAccessory() {
        switch appSettings.currentThemeName {
        case .systemDefault:
            themeAccessoryText.text = UserText.themeAccessoryDefault
        case .light:
            themeAccessoryText.text = UserText.themeAccessoryLight
        case .dark:
            themeAccessoryText.text = UserText.themeAccessoryDark
        }
    }

    private func configureIconViews() {
        if AppIconManager.shared.isAppIconChangeSupported {
            appIconImageView.image = AppIconManager.shared.appIcon.smallImage
        } else {
            appIconCell.isHidden = true
        }
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
    
    private func configureDoNotSell() {
        doNotSellAccessoryText.text = appSettings.sendDoNotSell ? "Enabled" : "Disabled"
    }
     
    private func configureRememberLogins() {
        if #available(iOS 13, *) {
            rememberLoginsAccessoryText.text = PreserveLogins.shared.allowedDomains.isEmpty ? "" : "\(PreserveLogins.shared.allowedDomains.count)"
        } else {
            rememberLoginsCell.isHidden = true
        }
    }

    private func configureVersionText() {
        versionText.text = versionProvider.localized
    }
    
    private func configureUniversalLinksToggle() {
        openUniversalLinksToggle.isOn = appSettings.allowUniversalLinks
    }

    private func configureLinkPreviewsToggle() {
        if #available(iOS 13, *) {
            longPressCell.isHidden = false
        }
        longPressPreviewsToggle.isOn = appSettings.longPressPreviews
    }

    private func showDebug() {
        // Use the "AdhocDebug" scheme when archiving to create a compatible adhoc build
        guard isDebugBuild else { return }
        performSegue(withIdentifier: "Debug", sender: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let cell = tableView.cellForRow(at: indexPath)

        switch cell {

        case defaultBrowserCell:
            Pixel.fire(pixel: .defaultBrowserButtonPressedSettings)
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)

        case versionCell:
            showDebug()

        default: break
        }

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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        return cell.isHidden ? 0 : UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let showDefaultBrowserSection = SettingsViewController.shouldShowDefaultBrowserSection
        if defaultBroswerSectionIndex == section, !showDefaultBrowserSection {
            return 22.0
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let showDefaultBrowserSection = SettingsViewController.shouldShowDefaultBrowserSection
        if defaultBroswerSectionIndex == section, !showDefaultBrowserSection {
            return CGFloat.leastNonzeroMagnitude
        } else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let showDefaultBrowserSection = SettingsViewController.shouldShowDefaultBrowserSection
        if defaultBroswerSectionIndex == section, !showDefaultBrowserSection {
            return nil
        } else {
            return super.tableView(tableView, titleForFooterInSection: section)
        }
    }

    @IBAction func onAuthenticationToggled(_ sender: UISwitch) {
        privacyStore.authenticationEnabled = sender.isOn
    }

    @IBAction func onDonePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onAutocompleteToggled(_ sender: UISwitch) {
        appSettings.autocomplete = sender.isOn
    }
    
    @IBAction func onAllowUniversalLinksToggled(_ sender: UISwitch) {
        appSettings.allowUniversalLinks = sender.isOn
    }

    @IBAction func onLinkPreviewsToggle(_ sender: UISwitch) {
        appSettings.longPressPreviews = sender.isOn
        Pixel.fire(pixel: appSettings.longPressPreviews ? .settingsLinkPreviewsOn : .settingsLinkPreviewsOff)
    }
}

extension SettingsViewController: Themable {
    
    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
        configureThemeCellAccessory()
        
        for label in labels {
            label.textColor = theme.tableCellTextColor
        }
        
        for label in accessoryLabels {
            label.textColor = theme.tableCellAccessoryTextColor
        }
        
        versionText.textColor = theme.tableCellTextColor
        
        autocompleteToggle.onTintColor = theme.buttonTintColor
        authenticationToggle.onTintColor = theme.buttonTintColor
        openUniversalLinksToggle.onTintColor = theme.buttonTintColor
        longPressPreviewsToggle.onTintColor = theme.buttonTintColor
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
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
