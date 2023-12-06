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

struct SettingsState {
    var isPresentingAddToDockView = false
    var isPresentingAddWidgetView = false
    var isPresentingSyncView = false
    var isPresentingLoginsView = false
    var loginsViewSelectedAccount: SecureVaultModels.WebsiteAccount?
    var isPresentingAppIconView = false
    
    var shouldShowSyncCell = false
    var shouldShowLoginsCell = false
    var appTheme: ThemeName = .systemDefault
    var appIcon: AppIcon = .defaultAppIcon
    var fireButtonAnimation: FireButtonAnimationType = .fireRising
}

final class SettingsViewModel: ObservableObject {

    private let bookmarksDatabase: CoreDataDatabase
    private lazy var emailManager = EmailManager()
    private lazy var versionProvider: AppVersion = AppVersion.shared
    fileprivate lazy var privacyStore = PrivacyUserDefaults()
    private lazy var animator: FireButtonAnimator = FireButtonAnimator(appSettings: AppUserDefaults())
    fileprivate lazy var variantManager = AppDependencyProvider.shared.variantManager
    fileprivate lazy var featureFlagger = AppDependencyProvider.shared.featureFlagger
    
    private(set) lazy var appSettings = AppDependencyProvider.shared.appSettings
    let syncService: DDGSyncing
    let syncDataProviders: SyncDataProviders
    
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
    
    // MARK: 
    var appIconSubscription: AnyCancellable?
    
    @Published private(set) var state: SettingsState
    
    init(bookmarksDatabase: CoreDataDatabase,
         syncService: DDGSyncing,
         syncDataProviders: SyncDataProviders,
         internalUserDecider: InternalUserDecider,
         state: SettingsState = SettingsState()) {
        self.bookmarksDatabase = bookmarksDatabase
        self.syncService = syncService
        self.syncDataProviders = syncDataProviders
        self.internalUserDecider = internalUserDecider
        self.state = state
        configureView()
    }
    
    func configureView() {
        state.shouldShowSyncCell = featureFlagger.isFeatureOn(.sync)
        state.shouldShowLoginsCell = featureFlagger.isFeatureOn(.autofillAccessCredentialManagement)
        state.appTheme = appSettings.currentThemeName
        state.appIcon = AppIconManager.shared.appIcon
        createAppIconSubscriber()
        state.fireButtonAnimation = appSettings.currentFireButtonAnimation
    }
    
    private func createAppIconSubscriber() {
        appIconSubscription = AppIconManager.shared.$appIcon
            .sink { newIcon in
                self.state.appIcon = newIcon
            }
    }
    
    func openCookiePopupManagement() {
        // showCookiePopupManagement(animated: true)
    }
    
}

// MARK: User Actions
extension SettingsViewModel {
    
    func setAsDefaultBrowser() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    func setIsPresentingAddToDockView(_ value: Bool) {
        state.isPresentingAddToDockView = value
    }
    
    func setIsPresentingAddWidgetView(_ value: Bool) {
        state.isPresentingAddWidgetView = value
    }
    
    func setIsPresentingSyncView(_ value: Bool) {
        state.isPresentingSyncView = value
    }
    
    func setIsPresentingLoginsView(_ value: Bool) {
        state.isPresentingLoginsView = value
        if !state.isPresentingLoginsView {
            Pixel.fire(pixel: .autofillSettingsOpened)
        }
    }
    
    func setIsPresentingLoginsViewWithAccount(accountDetails: SecureVaultModels.WebsiteAccount) {
        state.loginsViewSelectedAccount = accountDetails
        setIsPresentingLoginsView(true)
    }
    
    func setTheme(theme: ThemeName) {
        appSettings.currentThemeName = theme
        state.appTheme = theme
        ThemeManager.shared.enableTheme(with: theme)
        ThemeManager.shared.updateUserInterfaceStyle()
    }
    
    func setIsPresentingAppIconView(_ value: Bool) {
        state.isPresentingAppIconView = value
    }
    
    func setFireButtonAnimation(_ value: FireButtonAnimationType, showAnimation: Bool = true) {
        appSettings.currentFireButtonAnimation = value
        NotificationCenter.default.post(name: AppUserDefaults.Notifications.currentFireButtonAnimationChange, object: self)
        
        if showAnimation {
            animator.animate {
                // no op
            } onTransitionCompleted: {
                // no op
            } completion: {
                // no op
            }
        }
        
    }
    
    func selectFireAnimation() {}
    func selectTextSize() {}
    func selectBarPosition() {}
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
        state.isPresentingLoginsView = false
    }
}
