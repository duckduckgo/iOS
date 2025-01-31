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
import SyncUI_iOS
import Persistence
import Common

class SettingsLegacyViewProvider: ObservableObject {

    enum StoryboardName {
        static let settings = "Settings"
        static let homeRow = "HomeRow"
        static let feedback = "Feedback"
    }

    let syncService: DDGSyncing
    let syncDataProviders: SyncDataProviders
    let appSettings: AppSettings
    let bookmarksDatabase: CoreDataDatabase
    let tabManager: TabManager
    let syncPausedStateManager: any SyncPausedStateManaging
    let fireproofing: Fireproofing
    let websiteDataManager: WebsiteDataManaging

    init(syncService: any DDGSyncing,
         syncDataProviders: SyncDataProviders,
         appSettings: any AppSettings,
         bookmarksDatabase: CoreDataDatabase,
         tabManager: TabManager,
         syncPausedStateManager: any SyncPausedStateManaging,
         fireproofing: Fireproofing,
         websiteDataManager: WebsiteDataManaging) {
        self.syncService = syncService
        self.syncDataProviders = syncDataProviders
        self.appSettings = appSettings
        self.bookmarksDatabase = bookmarksDatabase
        self.tabManager = tabManager
        self.syncPausedStateManager = syncPausedStateManager
        self.fireproofing = fireproofing
        self.websiteDataManager = websiteDataManager
    }
    
    enum LegacyView {
        case addToDock,
             sync,
             logins,
             appIcon,
             gpc,
             autoconsent,
             unprotectedSites,
             fireproofSites,
             autoclearData,
             keyboard,
             feedback,
             debug
    }

    private func instantiate(_ identifier: String, fromStoryboard name: String) -> UIViewController {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }

    private func instantiateFireproofingController() -> UIViewController {
        let storyboard = UIStoryboard(name: StoryboardName.settings, bundle: nil)
        return storyboard.instantiateViewController(identifier: "FireProofSites") { coder in
            return FireproofingSettingsViewController(coder: coder, fireproofing: self.fireproofing, websiteDataManager: self.websiteDataManager)
        }
    }

    private func instantiateAutoClearController() -> UIViewController {
        let storyboard = UIStoryboard(name: StoryboardName.settings, bundle: nil)
        return storyboard.instantiateViewController(identifier: "AutoClearSettingsViewController", creator: { coder in
            return AutoClearSettingsViewController(appSettings: self.appSettings, coder: coder)
        })
    }

    private func instantiateDebugController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Debug", bundle: nil)
        return storyboard.instantiateViewController(identifier: "DebugMenu") { coder in
            RootDebugViewController(coder: coder,
                                    sync: self.syncService,
                                    bookmarksDatabase: self.bookmarksDatabase,
                                    internalUserDecider: AppDependencyProvider.shared.internalUserDecider,
                                    tabManager: self.tabManager,
                                    fireproofing: self.fireproofing)
        }
    }

    // Legacy UIKit Views (Pushed unmodified)
    var addToDock: UIViewController { instantiate( "instructions", fromStoryboard: StoryboardName.homeRow) }
    var appIcon: UIViewController { instantiate("AppIcon", fromStoryboard: StoryboardName.settings) }
    var gpc: UIViewController { instantiate("DoNotSell", fromStoryboard: StoryboardName.settings) }
    var autoConsent: UIViewController { instantiate("AutoconsentSettingsViewController", fromStoryboard: StoryboardName.settings) }
    var unprotectedSites: UIViewController { instantiate("UnprotectedSites", fromStoryboard: StoryboardName.settings) }
    var fireproofSites: UIViewController { instantiateFireproofingController() }
    var keyboard: UIViewController { instantiate("Keyboard", fromStoryboard: StoryboardName.settings) }
    var feedback: UIViewController { instantiate("Feedback", fromStoryboard: StoryboardName.feedback) }
    var autoclearData: UIViewController { instantiateAutoClearController() }
    var debug: UIViewController { instantiateDebugController() }


    @MainActor
    func syncSettings(source: String? = nil) -> SyncSettingsViewController {
        return SyncSettingsViewController(syncService: self.syncService,
                                          syncBookmarksAdapter: self.syncDataProviders.bookmarksAdapter,
                                          syncCredentialsAdapter: self.syncDataProviders.credentialsAdapter,
                                          appSettings: self.appSettings,
                                          syncPausedStateManager: self.syncPausedStateManager,
                                          source: source)
    }
    
    func loginSettings(delegate: AutofillLoginSettingsListViewControllerDelegate,
                       selectedAccount: SecureVaultModels.WebsiteAccount?) -> AutofillLoginSettingsListViewController {
        return AutofillLoginSettingsListViewController(appSettings: self.appSettings,
                                                       syncService: self.syncService,
                                                       syncDataProviders: self.syncDataProviders,
                                                       selectedAccount: selectedAccount,
                                                       source: .settings)
    }

}
