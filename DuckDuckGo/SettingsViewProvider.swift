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

class SettingsViewProvider: ObservableObject {
    
    let syncService: DDGSyncing
    let syncDataProviders: SyncDataProviders
    let appSettings: AppSettings
    
    init(syncService: DDGSyncing, syncDataProviders: SyncDataProviders, appSettings: AppSettings) {
        self.syncService = syncService
        self.syncDataProviders = syncDataProviders
        self.appSettings = appSettings
    }
    
    var addToDock: UIViewController {
        let storyboard = UIStoryboard(name: "HomeRow", bundle: nil)
        return storyboard.instantiateViewController(identifier: "instructions") as! HomeRowInstructionsViewController
    }
    
    var addWidget: some View {
        return WidgetEducationView()
    }

    var textSettings: UIViewController {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        return storyboard.instantiateViewController(identifier: "TextSize") as! TextSizeSettingsViewController
    }
    
    var syncSettings: some View {
        return SyncSettingsViewControllerRepresentable(syncService: syncService, syncDataProviders: syncDataProviders)
    }
    
    func loginSettings(delegate: AutofillLoginSettingsListViewControllerDelegate,
                       selectedAccount: SecureVaultModels.WebsiteAccount?) -> some View {
            AutofillLoginSettingsListViewControllerRepresentable(appSettings: appSettings,
                                                                 syncService: syncService,
                                                                 syncDataProviders: syncDataProviders,
                                                                 delegate: delegate,
                                                                 selectedAccount: selectedAccount)
    }
    
    var appIcon: some View {
        AppIconSettingsViewControllerRepresentable()
    }
    
    var doNotSell: some View {
        DoNotSellSettingsViewControllerRepresentable()
    }
    
    var autoConsent: some View {
        AutoconsentSettingsViewControllerRepresentable()
    }
    
    var unprotectedSites: some View {
        UnprotectedSitesViewControllerRepresentable()
    }
    
    var fireproofSites: some View {
        PreserveLoginsSettingsViewControllerRepresentable()
    }
    
    var autoclearData: some View {
        AutoClearSettingsViewControllerRepresentable()
    }
    

}
