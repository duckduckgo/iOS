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
import Core
import BrowserServicesKit
import Persistence
import SwiftUI
import Common
import DDGSync
import Combine

#if APP_TRACKING_PROTECTION
import NetworkExtension
#endif

#if NETWORK_PROTECTION
import NetworkProtection
#endif

// swiftlint:disable file_length type_body_length
class SettingsViewController: UITableViewController {

    @IBOutlet weak var defaultBrowserCell: UITableViewCell!
    @IBOutlet weak var themeAccessoryText: UILabel!
    @IBOutlet weak var fireButtonAnimationAccessoryText: UILabel!
    @IBOutlet weak var addressBarPositionCell: UITableViewCell!
    @IBOutlet weak var addressBarPositionAccessoryText: UILabel!
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
    @IBOutlet weak var netPCell: UITableViewCell!
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
    private let appearanceSectionIndex = 3
    private let moreFromDDGSectionIndex = 6
    private let debugSectionIndex = 8
    
    private let bookmarksDatabase: CoreDataDatabase

    private lazy var emailManager = EmailManager()
    
    private lazy var versionProvider: AppVersion = AppVersion.shared
    fileprivate lazy var privacyStore = PrivacyUserDefaults()
    fileprivate lazy var appSettings = AppDependencyProvider.shared.appSettings
    fileprivate lazy var variantManager = AppDependencyProvider.shared.variantManager
    fileprivate lazy var featureFlagger = AppDependencyProvider.shared.featureFlagger
    fileprivate let syncService: DDGSyncing
    fileprivate let syncDataProviders: SyncDataProviders
    fileprivate let internalUserDecider: InternalUserDecider
#if NETWORK_PROTECTION
    private let connectionObserver = ConnectionStatusObserverThroughSession()
#endif
    private var cancellables: Set<AnyCancellable> = []

    private var shouldShowDebugCell: Bool {
        return featureFlagger.isFeatureOn(.debugMenu) || isDebugBuild
    }
    
    private var shouldShowVoiceSearchCell: Bool {
        AppDependencyProvider.shared.voiceSearchHelper.isSpeechRecognizerAvailable
    }

    private var shouldShowAutofillCell: Bool {
        return featureFlagger.isFeatureOn(.autofillAccessCredentialManagement)
    }

    private var shouldShowSyncCell: Bool {
        return featureFlagger.isFeatureOn(.sync)
    }

    private var shouldShowTextSizeCell: Bool {
        return UIDevice.current.userInterfaceIdiom != .pad
    }

    private var shouldShowAddressBarPositionCell: Bool {
        return UIDevice.current.userInterfaceIdiom != .pad
    }

    private lazy var shouldShowNetPCell: Bool = {
#if NETWORK_PROTECTION
        if #available(iOS 15, *) {
            return featureFlagger.isFeatureOn(.networkProtection)
        } else {
            return false
        }
#else
        return false
#endif
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureAutofillCell()
        configureSyncCell()
        configureThemeCellAccessory()
        configureFireButtonAnimationCellAccessory()
        configureAddressBarPositionCell()
        configureTextSizeCell()
        configureDisableAutocompleteToggle()
        configureSecurityToggles()
        configureVersionText()
        configureUniversalLinksToggle()
        configureLinkPreviewsToggle()
        configureRememberLogins()
        configureDebugCell()
        configureVoiceSearchCell()
        configureNetPCell()
        applyTheme(ThemeManager.shared.currentTheme)

        internalUserDecider.isInternalUserPublisher.dropFirst().sink(receiveValue: { [weak self] _ in
            self?.configureAutofillCell()
            self?.configureSyncCell()
            self?.configureDebugCell()
            self?.tableView.reloadData()

            // Scroll to force-redraw section headers and footers
            self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        })
        .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureFireButtonAnimationCellAccessory()
        configureAddressBarPositionCell()
        configureTextSizeCell()
        configureAutoClearCellAccessory()
        configureRememberLogins()
        configureDoNotSell()
        configureAutoconsent()
        configureIconViews()
        configureEmailProtectionAccessoryText()
        configureMacBrowserWaitlistCell()
        configureWindowsBrowserWaitlistCell()
        configureSyncCell()

#if NETWORK_PROTECTION
        updateNetPCellSubtitle(connectionStatus: connectionObserver.recentValue)
#endif

        // Make sure multiline labels are correctly presented
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
    }

    init?(coder: NSCoder,
          bookmarksDatabase: CoreDataDatabase,
          syncService: DDGSyncing,
          syncDataProviders: SyncDataProviders,
          internalUserDecider: InternalUserDecider) {

        self.bookmarksDatabase = bookmarksDatabase
        self.syncService = syncService
        self.syncDataProviders = syncDataProviders
        self.internalUserDecider = internalUserDecider
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    func openLogins() {
        showAutofill()
    }

    func openLogins(accountDetails: SecureVaultModels.WebsiteAccount) {
        showAutofillAccountDetails(accountDetails)
    }

    func openCookiePopupManagement() {
        showCookiePopupManagement(animated: true)
    }

    @IBSegueAction func onCreateRootDebugScreen(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> RootDebugViewController {
        guard let controller = RootDebugViewController(coder: coder,
                                                       sync: syncService,
                                                       bookmarksDatabase: bookmarksDatabase,
                                                       internalUserDecider: AppDependencyProvider.shared.internalUserDecider) else {
            fatalError("Failed to create controller")
        }

        return controller
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
        syncCell.textLabel?.text = "Sync & Backup"
        if SyncBookmarksAdapter.isSyncBookmarksPaused || SyncCredentialsAdapter.isSyncCredentialsPaused {
            syncCell.textLabel?.text = "⚠️ " + "Sync & Backup"
        }
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

    private func configureAddressBarPositionCell() {
        addressBarPositionCell.isHidden = !shouldShowAddressBarPositionCell
        addressBarPositionAccessoryText.text = appSettings.currentAddressBarPosition.descriptionText
    }

    private func configureTextSizeCell() {
        textSizeCell.isHidden = !shouldShowTextSizeCell
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

    private func configureNetPCell() {
        netPCell.isHidden = !shouldShowNetPCell
#if NETWORK_PROTECTION
        updateNetPCellSubtitle(connectionStatus: connectionObserver.recentValue)
        connectionObserver.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.updateNetPCellSubtitle(connectionStatus: status)
            }
            .store(in: &cancellables)
#endif
    }

#if NETWORK_PROTECTION
    private func updateNetPCellSubtitle(connectionStatus: ConnectionStatus) {
        switch NetworkProtectionAccessController().networkProtectionAccessType() {
        case .none, .waitlistAvailable, .waitlistJoined, .waitlistInvitedPendingTermsAcceptance:
            netPCell.detailTextLabel?.text = VPNWaitlist.shared.settingsSubtitle
        case .waitlistInvited, .inviteCodeInvited:
            switch connectionStatus {
            case .connected: netPCell.detailTextLabel?.text = UserText.netPCellConnected
            default: netPCell.detailTextLabel?.text = UserText.netPCellDisconnected
            }
        }
    }
#endif

    private func configureDebugCell() {
        debugCell.isHidden = !shouldShowDebugCell
    }

    func showSync(animated: Bool = true) {
        let controller = SyncSettingsViewController(syncService: syncService, syncBookmarksAdapter: syncDataProviders.bookmarksAdapter)
        navigationController?.pushViewController(controller, animated: animated)
    }

    private func showAutofill(animated: Bool = true) {
        let autofillController = AutofillLoginSettingsListViewController(
            appSettings: appSettings,
            syncService: syncService,
            syncDataProviders: syncDataProviders
        )
        autofillController.delegate = self
        Pixel.fire(pixel: .autofillSettingsOpened)
        navigationController?.pushViewController(autofillController, animated: animated)
    }
    
    func showAutofillAccountDetails(_ account: SecureVaultModels.WebsiteAccount) {
        let autofillController = AutofillLoginSettingsListViewController(
            appSettings: appSettings,
            syncService: syncService,
            syncDataProviders: syncDataProviders
        )
        autofillController.delegate = self
        let detailsController = autofillController.makeAccountDetailsScreen(account)

        var controllers = navigationController?.viewControllers ?? []
        controllers.append(autofillController)
        controllers.append(detailsController)
        navigationController?.viewControllers = controllers
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

#if NETWORK_PROTECTION
    @available(iOS 15, *)
    private func showNetP() {
        switch NetworkProtectionAccessController().networkProtectionAccessType() {
        case .inviteCodeInvited, .waitlistInvited:
            // This will be tidied up as part of https://app.asana.com/0/0/1205084446087078/f
            let rootViewController = NetworkProtectionRootViewController { [weak self] in
                self?.navigationController?.popViewController(animated: true)
                let newRootViewController = NetworkProtectionRootViewController()
                self?.pushNetP(newRootViewController)
            }

            pushNetP(rootViewController)
        default:
            navigationController?.pushViewController(VPNWaitlistViewController(nibName: nil, bundle: nil), animated: true)
        }
    }

    @available(iOS 15, *)
    private func pushNetP(_ rootViewController: NetworkProtectionRootViewController) {
        navigationController?.pushViewController(
            rootViewController,
            animated: true
        )
    }
#endif

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

        case netPCell:
            if #available(iOS 15, *) {
#if NETWORK_PROTECTION
                showNetP()
#else
                break
#endif
            }
        default: break
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor

        if cell == netPCell {
            DailyPixel.fire(pixel: .networkProtectionSettingsRowDisplayed)
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
    
    /// Only use this to hide the header if the entire section can be conditionally hidden.
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
    
    /// Only use this to hide the footer if the entire section can be conditionally hidden.
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
    
    /// Only use this if the *last cell* in the section is to be conditionally hidden in order to retain the section rounding.
    ///  If your cell is not the last you don't need to modify the number of rows.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = super.tableView(tableView, numberOfRowsInSection: section)
        if section == moreFromDDGSectionIndex && !shouldShowNetPCell {
            return rows - 1
        } else if section == appearanceSectionIndex && UIDevice.current.userInterfaceIdiom == .pad {
            // Both the text size and bottom bar settings are at the end of the section so need to reduce the section size appropriately
            return rows - 2
        } else {
            return rows
        }
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

    @IBAction func onAboutTapped() {
        navigationController?.pushViewController(AboutViewController(), animated: true)
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
        view.backgroundColor = theme.backgroundColor

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
