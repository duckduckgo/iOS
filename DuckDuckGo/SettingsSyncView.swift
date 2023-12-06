//
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

struct SettingsSyncView: View {
    
    @EnvironmentObject var viewModel: SettingsViewModel
    @State var isPresentingSyncView: Bool = false
    
    var body: some View {
        let syncSettingsController = SyncSettingsViewControllerRepresentable(syncService: viewModel.syncService,
                                                                             syncDataProviders: viewModel.syncDataProviders)
        if viewModel.state.shouldShowSyncCell {
            Section {
                NavigationLink(destination: syncSettingsController, isActive: $isPresentingSyncView) {
                    PlainCell(label: UserText.syncTitle, action: { viewModel.setIsPresentingSyncView(true) })
                }
            }
            
            .onAppear {
                isPresentingSyncView = viewModel.state.isPresentingSyncView
            }
            
            .onChange(of: viewModel.state.isPresentingSyncView) { newValue in
                isPresentingSyncView = newValue
            }
            
            .onChange(of: isPresentingSyncView) { newValue in
                viewModel.setIsPresentingSyncView(newValue)
            }
        }
    }
}

// TODO: Sync is already SwiftUI - This should be migrated to a SwiftUI View
struct SyncSettingsViewControllerRepresentable: UIViewControllerRepresentable {
    
    let syncService: DDGSyncing
    let syncDataProviders: SyncDataProviders
    
    typealias UIViewControllerType = SyncSettingsViewController

    class Coordinator {
        var parentObserver: NSKeyValueObservation?
    }

    func makeUIViewController(context: Context) -> SyncSettingsViewController {
        let viewController =  SyncSettingsViewController(syncService: syncService,
                                          syncBookmarksAdapter: syncDataProviders.bookmarksAdapter)
        context.coordinator.parentObserver = viewController.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.title = vc.title
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })
        return viewController
    }

    func updateUIViewController(_ uiViewController: SyncSettingsViewController, context: Context) {}

    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}
