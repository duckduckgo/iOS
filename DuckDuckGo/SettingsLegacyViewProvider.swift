//
//  LegacyViewProvider.swift
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

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: some View {
        build()
    }
}

class SettingsLegacyViewProvider: ObservableObject {
    
    let syncService: DDGSyncing
    let syncDataProviders: SyncDataProviders
    let appSettings: AppSettings
    
    init(syncService: DDGSyncing, syncDataProviders: SyncDataProviders, appSettings: AppSettings) {
        self.syncService = syncService
        self.syncDataProviders = syncDataProviders
        self.appSettings = appSettings
    }
    
    // Legacy UIKit Views (Pushed unmodified)
    var addToDock: UIViewController {
        let storyboard = UIStoryboard(name: "HomeRow", bundle: nil)
        return storyboard.instantiateViewController(identifier: "instructions") as! HomeRowInstructionsViewController
    }
    
    @MainActor
    var syncSettings: UIViewController {
        return SyncSettingsViewController(syncService: self.syncService,
                                          syncBookmarksAdapter: self.syncDataProviders.bookmarksAdapter,
                                          appSettings: self.appSettings)
    }
    
    func loginSettings(delegate: AutofillLoginSettingsListViewControllerDelegate,
                       selectedAccount: SecureVaultModels.WebsiteAccount?) -> AutofillLoginSettingsListViewController {
        return AutofillLoginSettingsListViewController(appSettings: self.appSettings,
                                                       syncService: self.syncService,
                                                       syncDataProviders: self.syncDataProviders,
                                                       selectedAccount: selectedAccount)
    }
    
    var textSettings: UIViewController {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        return storyboard.instantiateViewController(identifier: "TextSize") as! TextSizeSettingsViewController
    }
    
    var appIcon: UIViewController {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        return storyboard.instantiateViewController(identifier: "AppIcon") as! AppIconSettingsViewController
    }
    
    var gpc: UIViewController {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        return storyboard.instantiateViewController(identifier: "DoNotSell") as! DoNotSellSettingsViewController
    }
    
    var autoConsent: UIViewController {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        return storyboard.instantiateViewController(identifier: "AutoconsentSettingsViewController") as! AutoconsentSettingsViewController
    }
    
    var unprotectedSites: UIViewController {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        return storyboard.instantiateViewController(identifier: "UnprotectedSites") as! UnprotectedSitesViewController
    }
    
    var fireproofSites: UIViewController {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        return storyboard.instantiateViewController(identifier: "FireProofSites") as! PreserveLoginsSettingsViewController
    }
    
    var autoclearData: UIViewController {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        return storyboard.instantiateViewController(identifier: "AutoClearSettingsViewController") as! AutoClearSettingsViewController
    }
    
    var keyboard: UIViewController {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        return storyboard.instantiateViewController(identifier: "Keyboard") as! KeyboardSettingsViewController
    }
}
