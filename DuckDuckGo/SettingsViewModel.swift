//
//  SettingsViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

final class SettingsViewModel: ObservableObject {
    
    // MARK: 
    var appIconSubscription: AnyCancellable?
    var stateSubscriber: AnyCancellable?
    
    // Closure to request a legacy view controller presentation
    var onRequestPushLegacyView: ((UIViewController) -> Void)?
    var onRequestPresentLegacyView: ((UIViewController, _ modal: Bool) -> Void)?
    
    private(set) var model: SettingsModel
    @Published private(set) var state: SettingsState
    
    // MARK: Presentation
    var isPresentingAddToDockView: Bool = false
    var isPresentingAddWidgetView = false
    var isPresentingSyncView = false
    var isPresentingLoginsView = false
    var isPresentingAppIconView = false
    var isPresentingTextSettingsView = false
    
    var shouldShowSyncCell: Bool { model.isFeatureAvailable(.sync) }
    var shouldShowLoginsCell: Bool { model.isFeatureAvailable(.autofillAccessCredentialManagement) }
    var shouldShowTextSizeCell: Bool { model.isFeatureAvailable(.textSize) }
    var shouldShowDebugCell: Bool { model.isFeatureAvailable(.networkProtection) }
    var shouldShowVoiceSearchCell: Bool { model.isFeatureAvailable(.voiceSearch) }
    var shouldShowAddressBarPositionCell: Bool { model.isFeatureAvailable(.addressbarPosition) }
    var shouldShowNetworkProtectionCell: Bool { model.isFeatureAvailable(.networkProtection) }
        
    init(model: SettingsModel, state: SettingsState = SettingsState(general: SettingsStateGeneral())) {
        self.model = model
        self.state = state
    }
    
    func configureView() {
        state.general.appIcon = model.appIconManager.appIcon
        state.general.fireButtonAnimation = model.appSettings.currentFireButtonAnimation
        state.general.appTheme = model.appSettings.currentThemeName
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        
        appIconSubscription = model.appIconManager.$appIcon
            .sink { newIcon in
                self.state.general.appIcon = newIcon
            }
    }
    
    func openCookiePopupManagement() {
        // showCookiePopupManagement(animated: true)
    }
    
}

// MARK: Legacy View Presentation
// These UIKit views have issues when presented via UIHostingController so
// we fall back to UIKit navigation
extension SettingsViewModel {
    
    private func pushLegacyView(_ view: UIViewController) {
        onRequestPushLegacyView?(view)
    }
    
    private func presentLegacyView(_ view: UIViewController, modal: Bool) {
        onRequestPresentLegacyView?(view, modal)
    }

    func shouldPresentAddToDockView() {
        let storyboard = UIStoryboard(name: "HomeRow", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "instructions") as! HomeRowInstructionsViewController
        presentLegacyView(viewController, modal: true)
        isPresentingAddToDockView = false
    }
    
    func shouldPresentTextSettingsView() {
        Pixel.fire(pixel: .textSizeSettingsShown)
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "TextSize") as! TextSizeSettingsViewController
        pushLegacyView(controller)
        isPresentingTextSettingsView = false
    }
    
}

// MARK: User Actions
extension SettingsViewModel {
    
    func setAsDefaultBrowser() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    func setIsPresentingLoginsViewWithAccount(accountDetails: SecureVaultModels.WebsiteAccount) {
        state.general.activeWebsiteAccount = accountDetails
        isPresentingLoginsView = true
    }
    
    func setTheme(_ theme: ThemeName) {
        model.setTheme(theme: theme)
        state.general.appTheme = theme
    }
    
    func setIsPresentingAppIconView(_ value: Bool) {
        isPresentingAppIconView = value
    }

    func setFireButtonAnimation(_ value: FireButtonAnimationType) {
        model.setFireButtonAnimetion(value)
        state.general.fireButtonAnimation = value
    }
    
    func selectBarPosition() {}
}

extension SettingsViewModel {
    
    var autofillControllerRepresentable: AutofillLoginSettingsListViewControllerRepresentable {
        return AutofillLoginSettingsListViewControllerRepresentable(appSettings: model.appSettings,
                                                                                       syncService: model.syncService,
                                                                                       syncDataProviders: model.syncDataProviders,
                                                                                       delegate: self,
                                                                    selectedAccount: state.general.activeWebsiteAccount)
    }
    
    var syncSettingsControllerRepresentable: SyncSettingsViewControllerRepresentable { return SyncSettingsViewControllerRepresentable(syncService: model.syncService,
                                                syncDataProviders: model.syncDataProviders)
    }
}


extension SettingsViewModel {
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

extension SettingsViewModel: AutofillLoginSettingsListViewControllerDelegate {
    func autofillLoginSettingsListViewControllerDidFinish(_ controller: AutofillLoginSettingsListViewController) {
        isPresentingLoginsView = false
    }
}
