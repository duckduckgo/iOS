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
        if viewModel.shouldShowLoginsCell {
            Section {
                NavigationLink(destination: LazyView(viewModel.autofillControllerRepresentable),
                               isActive: $viewModel.isPresentingLoginsView) {
                    SettingsCellView(label: UserText.autofillLoginListTitle,
                                     action: { viewModel.isPresentingLoginsView = true })
                    
                }
            }
    
        }
            
    }
 
}
