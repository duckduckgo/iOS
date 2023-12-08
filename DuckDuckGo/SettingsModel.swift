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

class SettingsModel: ObservableObject {
        
    private let appIconManager = AppIconManager.shared
    private let bookmarksDatabase: CoreDataDatabase
    private let internalUserDecider: InternalUserDecider
    private lazy var featureFlagger = AppDependencyProvider.shared.featureFlagger
    private lazy var animator: FireButtonAnimator = FireButtonAnimator(appSettings: AppUserDefaults())
    private(set) lazy var appSettings = AppDependencyProvider.shared.appSettings
    private lazy var isPad = UIDevice.current.userInterfaceIdiom == .pad
    private var privacyStore = PrivacyUserDefaults()
    private var cancellables = Set<AnyCancellable>()
    
    var appIcon: AppIcon = AppIcon.defaultAppIcon
    var textSize: Int { appSettings.textSize }
    var sendDoNotSell: Bool { appSettings.sendDoNotSell }
    var autoconsentEnabled: Bool { appSettings.autoconsentEnabled }
    var longPressPreviews: Bool { appSettings.longPressPreviews }
    var allowUniversalLinks: Bool { appSettings.allowUniversalLinks }
    
    var fireButtonAnimation: FireButtonAnimationType {
        get { appSettings.currentFireButtonAnimation }
        set {
            appSettings.currentFireButtonAnimation = newValue
            NotificationCenter.default.post(name: AppUserDefaults.Notifications.currentFireButtonAnimationChange, object: self)
            
            animator.animate {
                // no op
            } onTransitionCompleted: {
                // no op
            } completion: {
                // no op
            }
        }
    }
    
    var appTheme: ThemeName {
        get { appSettings.currentThemeName }
        set {
            appSettings.currentThemeName = newValue
            ThemeManager.shared.enableTheme(with: newValue)
            ThemeManager.shared.updateUserInterfaceStyle()
        }
    }
    
    var addressBarPosition: AddressBarPosition {
        get { appSettings.currentAddressBarPosition }
        set { appSettings.currentAddressBarPosition = newValue }
    }
    
    var autoclearDataEnabled: Bool {
        if AutoClearSettingsModel(settings: appSettings) != nil {
            return true
        } else {
            return false
        }
    }
    var applicationLock: Bool {
        get { privacyStore.authenticationEnabled }
        set { privacyStore.authenticationEnabled = newValue }
    }
    
    var autocomplete: Bool {
        get { appSettings.autocomplete }
        set { appSettings.autocomplete = newValue }
    }
    
    var voiceSearchEnabled: Bool {
        get {
            appSettings.voiceSearchEnabled && AppDependencyProvider.shared.voiceSearchHelper.isSpeechRecognizerAvailable }
        set {
            appSettings.voiceSearchEnabled = newValue
        }
    }

#if NETWORK_PROTECTION
    private let connectionObserver = ConnectionStatusObserverThroughSession()
#endif
    
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
        case speechRecognition

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
        case .speechRecognition:
            return AppDependencyProvider.shared.voiceSearchHelper.isSpeechRecognizerAvailable
        }
    }
    
    func enableVoiceSearch(completion: @escaping (Bool) -> Void) {
        let isFirstTimeAskingForPermission = SpeechRecognizer.recordPermission == .undetermined

        SpeechRecognizer.requestMicAccess { permission in
            if !permission {
                completion(false)
                return
            }
            AppDependencyProvider.shared.voiceSearchHelper.enableVoiceSearch(true)
            completion(true)
        }
    }
    
}
