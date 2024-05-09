//
//  SettingsLegacyViewProvider.swift
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

import UIKit
import SwiftUI
import DDGSync
import Core
import BrowserServicesKit
import SyncUI
import Persistence
import Common

class SettingsLegacyViewProvider: ObservableObject {

    let syncService: DDGSyncing
    let syncDataProviders: SyncDataProviders
    let appSettings: AppSettings
    let bookmarksDatabase: CoreDataDatabase
    let tabManager: TabManager
    let syncPausedStateManager: any SyncPausedStateManaging

    init(syncService: any DDGSyncing,
         syncDataProviders: SyncDataProviders,
         appSettings: any AppSettings,
         bookmarksDatabase: CoreDataDatabase,
         tabManager: TabManager,
                                                                     syncPausedStateManager: any SyncPausedStateManaging) {
        self.syncService = syncService
        self.syncDataProviders = syncDataProviders
        self.appSettings = appSettings
        self.bookmarksDatabase = bookmarksDatabase
        self.tabManager = tabManager
        self.syncPausedStateManager =                                                             syncPausedStateManager
    }
    
    enum LegacyView {
        case addToDock,
             sync,
             logins,
             textSize,
             appIcon,
             gpc,
             autoconsent,
             unprotectedSites,
             fireproofSites,
             autoclearData,
             keyboard,
             netP,
             about,
             feedback, debug
    }
    
    private func instantiate(_ identifier: String, fromStoryboard name: String) -> UIViewController {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    
    // Legacy UIKit Views (Pushed unmodified)
    var addToDock: UIViewController { instantiate( "instructions", fromStoryboard: "HomeRow") }
    var textSettings: UIViewController { return instantiate("TextSize", fromStoryboard: "Settings") }
    var appIcon: UIViewController { instantiate("AppIcon", fromStoryboard: "Settings") }
    var gpc: UIViewController { instantiate("DoNotSell", fromStoryboard: "Settings") }
    var autoConsent: UIViewController { instantiate("AutoconsentSettingsViewController", fromStoryboard: "Settings") }
    var unprotectedSites: UIViewController { instantiate("UnprotectedSites", fromStoryboard: "Settings") }
    var fireproofSites: UIViewController { instantiate("FireProofSites", fromStoryboard: "Settings") }
    var autoclearData: UIViewController { instantiate("AutoClearSettingsViewController", fromStoryboard: "Settings") }
    var keyboard: UIViewController { instantiate("Keyboard", fromStoryboard: "Settings") }
    var feedback: UIViewController { instantiate("Feedback", fromStoryboard: "Feedback") }
    var about: UIViewController { AboutViewControllerOld() }

    @available(iOS 15, *)
    var netPWaitlist: UIViewController { VPNWaitlistViewController(nibName: nil, bundle: nil) }
    
    @available(iOS 15, *)
    var netP: UIViewController { NetworkProtectionRootViewController() }
    
    @MainActor
    var syncSettings: UIViewController {
        return SyncSettingsViewController(syncService: self.syncService,
                                          syncBookmarksAdapter: self.syncDataProviders.bookmarksAdapter,
                                          syncCredentialsAdapter: self.syncDataProviders.credentialsAdapter,
                                          appSettings: self.appSettings,
                                                                                    syncPausedStateManager: self.syncPausedStateManager)
    }
    
    func loginSettings(delegate: AutofillLoginSettingsListViewControllerDelegate,
                       selectedAccount: SecureVaultModels.WebsiteAccount?) -> AutofillLoginSettingsListViewController {
        return AutofillLoginSettingsListViewController(appSettings: self.appSettings,
                                                       syncService: self.syncService,
                                                       syncDataProviders: self.syncDataProviders,
                                                       selectedAccount: selectedAccount)
    }
    
    var debug: UIViewController {
        let storyboard = UIStoryboard(name: "Debug", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "DebugMenu") as? RootDebugViewController {
            viewController.configure(sync: syncService,
                                     bookmarksDatabase: bookmarksDatabase,
                                     internalUserDecider: AppDependencyProvider.shared.internalUserDecider,
                                     tabManager: tabManager)
            return viewController
        }
        return UIViewController()
    }
        
}
