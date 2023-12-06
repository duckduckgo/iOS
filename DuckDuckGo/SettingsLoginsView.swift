// TODO: Remove transition animation if showing a selected account//
//  GeneralSection.swift
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

import SwiftUI
import UIKit
import Core
import DDGSync
import BrowserServicesKit

struct SettingsLoginsView: View {
    
    @EnvironmentObject var viewModel: SettingsViewModel
    @State var isPresentingLoginsView: Bool = false
    
    var body: some View {
        if viewModel.state.shouldShowLoginsCell {
            let autofillController =  AutofillLoginSettingsListViewControllerRepresentable(appSettings: viewModel.appSettings,
                                                                                           syncService: viewModel.syncService,
                                                                                           syncDataProviders: viewModel.syncDataProviders,
                                                                                           delegate: viewModel,
                                                                                           selectedAccount: viewModel.state.loginsViewSelectedAccount)
            Section {
                // TODO: Remove transition animation if showing a selected account
                NavigationLink(destination: autofillController, isActive: $isPresentingLoginsView) {
                    PlainCell(label: UserText.autofillLoginListTitle, action: { viewModel.setIsPresentingLoginsView(true) })
                    
                }
            }
            
            .onAppear {
                isPresentingLoginsView = viewModel.state.isPresentingLoginsView
            }
            
            .onChange(of: isPresentingLoginsView) { _ in
                viewModel.setIsPresentingLoginsView(true)
            }
            
            .onChange(of: viewModel.state.isPresentingLoginsView) { newValue in
                isPresentingLoginsView = newValue
            }

        }
    }
 
}


struct AutofillLoginSettingsListViewControllerRepresentable: UIViewControllerRepresentable {
    
    let appSettings: AppSettings
    let syncService: DDGSyncing
    let syncDataProviders: SyncDataProviders
    let delegate: AutofillLoginSettingsListViewControllerDelegate
    let selectedAccount: SecureVaultModels.WebsiteAccount?
    
    typealias UIViewControllerType = AutofillLoginSettingsListViewController

    class Coordinator {
        var parentObserver: NSKeyValueObservation?
    }

    func makeUIViewController(context: Self.Context) -> AutofillLoginSettingsListViewController {
        let autofillController = AutofillLoginSettingsListViewController(
            appSettings: appSettings,
            syncService: syncService,
            syncDataProviders: syncDataProviders,
            selectedAccount: selectedAccount
        )
       
        context.coordinator.parentObserver = autofillController.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.title = vc.title
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
            
        })
        
        return autofillController
    }

    func updateUIViewController(_ uiViewController: AutofillLoginSettingsListViewController, context: Self.Context) {
        
    }

    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}
