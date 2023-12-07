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
        if viewModel.shouldShowSyncCell {
            Section {
                NavigationLink(destination: LazyView(viewModel.syncSettingsControllerRepresentable), isActive: $isPresentingSyncView) {
                    SettingsCellView(label: UserText.syncTitle,
                                     action: { viewModel.isPresentingSyncView = true })
                }
            }
                        
            .onChange(of: viewModel.isPresentingSyncView) { newValue in
                isPresentingSyncView = newValue
            }
        }
    }
}
