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
import BrowserServicesKit
import SwiftUI
import Common

// swiftlint:disable file_length type_body_length
class SettingsViewController: UITableViewController {

    @IBOutlet weak var defaultBrowserCell: UITableViewCell!
    @IBOutlet weak var themeAccessoryText: UILabel!
    @IBOutlet weak var fireButtonAnimationAccessoryText: UILabel!
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
    @IBOutlet weak var autoconsentCell: UITableViewCell!
    @IBOutlet weak var autoconsentAccessoryText: UILabel!
    @IBOutlet weak var emailProtectionCell: UITableViewCell!
    @IBOutlet weak var emailProtectionAccessoryText: UILabel!
    @IBOutlet weak var macBrowserWaitlistCell: UITableViewCell!
    @IBOutlet weak var macBrowserWaitlistAccessoryText: UILabel!
    @IBOutlet weak var windowsBrowserWaitlistCell: UITableViewCell!
    @IBOutlet weak var windowsBrowserWaitlistAccessoryText: UILabel!
    @IBOutlet weak var longPressCell: UITableViewCell!
    @IBOutlet weak var versionCell: UITableViewCell!
    @IBOutlet weak var textSizeCell: UITableViewCell!
    @IBOutlet weak var textSizeAccessoryText: UILabel!
    @IBOutlet weak var widgetEducationCell: UITableViewCell!
    @IBOutlet weak var syncCell: UITableViewCell!
    @IBOutlet weak var autofillCell: UITableViewCell!
    @IBOutlet weak var debugCell: UITableViewCell!
    @IBOutlet weak var voiceSearchCell: UITableViewCell!
    @IBOutlet weak var voiceSearchToggle: UISwitch!
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var accessoryLabels: [UILabel]!
    
    private let syncSectionIndex = 1
    private let autofillSectionIndex = 2
    private let debugSectionIndex = 8

    private lazy var emailManager = EmailManager()
    
    private lazy var versionProvider: AppVersion = AppVersion.shared
    fileprivate lazy var privacyStore = PrivacyUserDefaults()
    fileprivate lazy var appSettings = AppDependencyProvider.shared.appSettings
    fileprivate lazy var variantManager = AppDependencyProvider.shared.variantManager
    fileprivate lazy var featureFlagger = AppDependencyProvider.shared.featureFlagger

    private var shouldShowDebugCell: Bool {
        return featureFlagger.isFeatureOn(.debugMenu)
    }
    
    private var shouldShowVoiceSearchCell: Bool {
        AppDependencyProvider.shared.voiceSearchHelper.isSpeechRecognizerAvailable
    }

    private lazy var shouldShowAutofillCell: Bool = {
        return featureFlagger.isFeatureOn(.autofillAccessCredentialManagement)
    }()

    private lazy var shouldShowSyncCell: Bool = {
        return featureFlagger.isFeatureOn(.sync)
    }()

    static func loadFromStoryboard() -> UIViewController {
        return UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController()!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureAutofillCell()
        configureSyncCell()
        configureThemeCellAccessory()
        configureFireButtonAnimationCellAccessory()
        configureTextSizeCell()
        configureDisableAutocompleteToggle()
        configureSecurityToggles()
        configureVersionText()
        configureUniversalLinksToggle()
        configureLinkPreviewsToggle()
        configureRememberLogins()
        configureDebugCell()
        configureVoiceSearchCell()
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureFireButtonAnimationCellAccessory()
        configureTextSizeCell()
        configureAutoClearCellAccessory()
        configureRememberLogins()
        configureDoNotSell()
        configureAutoconsent()
        configureIconViews()
        configureEmailProtectionAccessoryText()
        configureMacBrowserWaitlistCell()
        configureWindowsBrowserWaitlistCell()
        
        // Make sure muliline labels are correctly presented
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DoNotSellSettingsViewController {
            Pixel.fire(pixel: .settingsDoNotSellShown)
            return
        } else if segue.destination is AutoconsentSettingsViewController {
            Pixel.fire(pixel: .settingsAutoconsentShown)
            return
        } else if let textSizeSettings = segue.destination as? TextSizeSettingsViewController {
            Pixel.fire(pixel: .textSizeSettingsShown)
            presentationController?.delegate = textSizeSettings
            return
        }
                
        if let navController = segue.destination as? UINavigationController, navController.topViewController is FeedbackViewController {
            if UIDevice.current.userInterfaceIdiom == .pad {
                segue.destination.modalPresentationStyle = .formSheet
            }
        }
    }
    
    private func configureAutofillCell() {
        autofillCell.isHidden = !shouldShowAutofillCell
    }

    private func configureSyncCell() {
        syncCell.isHidden = !shouldShowSyncCell
    }

    private func configureVoiceSearchCell() {
        voiceSearchCell.isHidden = !shouldShowVoiceSearchCell
        voiceSearchToggle.isOn = appSettings.voiceSearchEnabled
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
    
    private func configureFireButtonAnimationCellAccessory() {
        fireButtonAnimationAccessoryText.text = appSettings.currentFireButtonAnimation.descriptionText
    }
    
    private func configureTextSizeCell() {
        textSizeCell.isHidden = UIDevice.current.userInterfaceIdiom == .pad
        textSizeAccessoryText.text = "\(appSettings.textSize)%"
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
        doNotSellAccessoryText.text = appSettings.sendDoNotSell ? UserText.doNotSellEnabled : UserText.doNotSellDisabled
    }
    
    private func configureAutoconsent() {
        autoconsentAccessoryText.text = appSettings.autoconsentEnabled ? UserText.autoconsentEnabled : UserText.autoconsentDisabled
    }
     
    private func configureRememberLogins() {
        rememberLoginsAccessoryText.text = PreserveLogins.shared.allowedDomains.isEmpty ? "" : "\(PreserveLogins.shared.allowedDomains.count)"
    }

    private func configureVersionText() {
        versionText.text = versionProvider.versionAndBuildNumber
    }
    
    private func configureUniversalLinksToggle() {
        openUniversalLinksToggle.isOn = appSettings.allowUniversalLinks
    }

    private func configureLinkPreviewsToggle() {
        longPressCell.isHidden = false
        longPressPreviewsToggle.isOn = appSettings.longPressPreviews
    }
    
    private func configureMacBrowserWaitlistCell() {
        macBrowserWaitlistCell.detailTextLabel?.text = MacBrowserWaitlist.shared.settingsSubtitle
    }

    private func configureWindowsBrowserWaitlistCell() {
        windowsBrowserWaitlistCell.isHidden = !WindowsBrowserWaitlist.shared.isAvailable

        if WindowsBrowserWaitlist.shared.isAvailable {
            windowsBrowserWaitlistCell.detailTextLabel?.text = WindowsBrowserWaitlist.shared.settingsSubtitle
        }
    }

    private func configureDebugCell() {
        debugCell.isHidden = !shouldShowDebugCell
    }

    private func showSync(animated: Bool = true) {
        let controller = SyncSettingsViewController()
        navigationController?.pushViewController(controller, animated: animated)
    }

    private func showAutofill(animated: Bool = true) {
        let autofillController = AutofillLoginSettingsListViewController(appSettings: appSettings)
        autofillController.delegate = self
        Pixel.fire(pixel: .autofillSettingsOpened)
        navigationController?.pushViewController(autofillController, animated: animated)
    }
    
    func showAutofillAccountDetails(_ account: SecureVaultModels.WebsiteAccount, animated: Bool = true) {
        let autofillController = AutofillLoginSettingsListViewController(appSettings: appSettings)
        autofillController.delegate = self
        navigationController?.pushViewController(autofillController, animated: animated)
        autofillController.showAccountDetails(account, animated: animated)
    }
    
    private func configureEmailProtectionAccessoryText() {
        if let userEmail = emailManager.userEmail {
            emailProtectionAccessoryText.text = userEmail
        } else {
            emailProtectionAccessoryText.text = UserText.emailSettingsSubtitle
        }
    }

    private func showEmailWebDashboard() {
        UIApplication.shared.open(URL.emailProtectionQuickLink, options: [:], completionHandler: nil)
    }

    private func showMacBrowserWaitlistViewController() {
        navigationController?.pushViewController(MacWaitlistViewController(nibName: nil, bundle: nil), animated: true)
    }

    private func showWindowsBrowserWaitlistViewController() {
        navigationController?.pushViewController(WindowsWaitlistViewController(nibName: nil, bundle: nil), animated: true)
    }

    func showCookiePopupManagement(animated: Bool = true) {
        navigationController?.pushViewController(AutoconsentSettingsViewController.loadFromStoryboard(), animated: animated)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let cell = tableView.cellForRow(at: indexPath)

        switch cell {
            
        case defaultBrowserCell:
            Pixel.fire(pixel: .defaultBrowserButtonPressedSettings)
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
            
        case emailProtectionCell:
            showEmailWebDashboard()
            
        case macBrowserWaitlistCell:
            showMacBrowserWaitlistViewController()

        case windowsBrowserWaitlistCell:
            showWindowsBrowserWaitlistViewController()

        case autofillCell:
            showAutofill()

        case syncCell:
            showSync()

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
        if syncSectionIndex == section && !shouldShowSyncCell {
            return CGFloat.leastNonzeroMagnitude
        } else if autofillSectionIndex == section && !shouldShowAutofillCell {
            return CGFloat.leastNonzeroMagnitude
        } else if debugSectionIndex == section && !shouldShowDebugCell {
            return CGFloat.leastNonzeroMagnitude
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if syncSectionIndex == section && !shouldShowSyncCell {
            return CGFloat.leastNonzeroMagnitude
        } else if autofillSectionIndex == section && !shouldShowAutofillCell {
            return CGFloat.leastNonzeroMagnitude
        } else if debugSectionIndex == section && !shouldShowDebugCell {
            return CGFloat.leastNonzeroMagnitude
        } else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return super.tableView(tableView, titleForFooterInSection: section)
    }

    @IBAction func onVoiceSearchToggled(_ sender: UISwitch) {
        var enableVoiceSearch = sender.isOn
        let isFirstTimeAskingForPermission = SpeechRecognizer.recordPermission == .undetermined
        
        SpeechRecognizer.requestMicAccess { permission in
            if !permission {
                enableVoiceSearch = false
                sender.setOn(false, animated: true)
                if !isFirstTimeAskingForPermission {
                    self.showNoMicrophonePermissionAlert()
                }
            }
            
            AppDependencyProvider.shared.voiceSearchHelper.enableVoiceSearch(enableVoiceSearch)
        }
    }
    
    private func showNoMicrophonePermissionAlert() {
        let alertController = NoMicPermissionAlert.buildAlert()
        present(alertController, animated: true, completion: nil)
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
        voiceSearchToggle.onTintColor = theme.buttonTintColor
        
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

extension SettingsViewController {
    static var fontSizeForHeaderView: CGFloat {
        let contentSize = UIApplication.shared.preferredContentSizeCategory
        switch contentSize {
        case .extraSmall:
            return 12
        case .small:
            return 12
        case .medium:
            return 12
        case .large:
            return 13
        case .extraLarge:
            return 15
        case .extraExtraLarge:
            return 17
        case .extraExtraExtraLarge:
            return 19
        case .accessibilityMedium:
            return 23
        case .accessibilityLarge:
            return 27
        case .accessibilityExtraLarge:
            return 33
        case .accessibilityExtraExtraLarge:
            return 38
        case .accessibilityExtraExtraExtraLarge:
            return 44
        default:
            return 13
        }
    }
}

// MARK: - AutofillLoginSettingsListViewControllerDelegate

extension SettingsViewController: AutofillLoginSettingsListViewControllerDelegate {
    func autofillLoginSettingsListViewControllerDidFinish(_ controller: AutofillLoginSettingsListViewController) {
        navigationController?.popViewController(animated: true)
    }
}
// swiftlint:enable file_length type_body_length
