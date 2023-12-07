//
//  SettingsState.swift
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

import Foundation
import BrowserServicesKit
import Persistence
import DDGSync
import Combine
import UIKit

#if APP_TRACKING_PROTECTION
import NetworkExtension
#endif

#if NETWORK_PROTECTION
import NetworkProtection
import Core
#endif

class SettingsModel {
        
    private let appIconManager = AppIconManager.shared
    private let bookmarksDatabase: CoreDataDatabase
    private let internalUserDecider: InternalUserDecider
    private lazy var featureFlagger = AppDependencyProvider.shared.featureFlagger
    private lazy var animator: FireButtonAnimator = FireButtonAnimator(appSettings: AppUserDefaults())
    private(set) lazy var appSettings = AppDependencyProvider.shared.appSettings
    private lazy var isPad = UIDevice.current.userInterfaceIdiom == .pad
    
    var appIcon: AppIcon = AppIcon.defaultAppIcon
    var fireButtonAnimation: FireButtonAnimationType { appSettings.currentFireButtonAnimation }
    var appTheme: ThemeName { appSettings.currentThemeName }
    var textSize: Int { appSettings.textSize }
    var addressBarPosition: AddressBarPosition { appSettings.currentAddressBarPosition }
    var sendDoNotSell: Bool { appSettings.sendDoNotSell }
    var autoconsentEnabled: Bool { appSettings.autoconsentEnabled }
    var autoclearDataEnabled: Bool {
        if AutoClearSettingsModel(settings: appSettings) != nil {
            return true
        } else {
            return false
        }
    }
    

#if NETWORK_PROTECTION
    private let connectionObserver = ConnectionStatusObserverThroughSession()
#endif
    private var cancellables: Set<AnyCancellable> = []
    
    init(bookmarksDatabase: CoreDataDatabase,
         internalUserDecider: InternalUserDecider) {
        self.bookmarksDatabase = bookmarksDatabase
        self.internalUserDecider = internalUserDecider
        setupSubscribers()
    }
    
    enum Features {
        case sync
        case autofillAccessCredentialManagement
        case textSize
        case voiceSearch
        case addressbarPosition

#if NETWORK_PROTECTION
        case networkProtection
#endif
    }
    
    func setupSubscribers() {
        
        appIconManager.$appIcon
            .sink { [weak self] newIcon in
                self?.appIcon = newIcon
            }
            .store(in: &cancellables)
    }
    
    func isFeatureAvailable(_ feature: Features) -> Bool {
        switch feature {
        case .sync:
            return featureFlagger.isFeatureOn(.sync)
        case .autofillAccessCredentialManagement:
            return featureFlagger.isFeatureOn(.autofillAccessCredentialManagement)
        case .textSize:
            return !isPad
        
        #if NETWORK_PROTECTION
        case .networkProtection:
            if #available(iOS 15, *) {
                return featureFlagger.isFeatureOn(.networkProtection)
            } else {
                return false
            }
        #endif
        
        case .voiceSearch:
            return AppDependencyProvider.shared.voiceSearchHelper.isSpeechRecognizerAvailable
        case .addressbarPosition:
            return !isPad
        }
    }
    
    func setTheme(theme: ThemeName) {
        appSettings.currentThemeName = theme
        ThemeManager.shared.enableTheme(with: theme)
        ThemeManager.shared.updateUserInterfaceStyle()
    }
    
    func setFireButtonAnimetion(_ value: FireButtonAnimationType) {
        appSettings.currentFireButtonAnimation = value
        NotificationCenter.default.post(name: AppUserDefaults.Notifications.currentFireButtonAnimationChange, object: self)
        
            animator.animate {
                // no op
            } onTransitionCompleted: {
                // no op
            } completion: {
                // no op
            }
    }
    
    func setAddressBarPosition(_ position: AddressBarPosition) {
        appSettings.currentAddressBarPosition = position
    }

}
