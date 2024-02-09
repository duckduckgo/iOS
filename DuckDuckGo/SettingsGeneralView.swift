//
//  SettingsGeneralView.swift
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

struct SettingsGeneralView: View {
    
    @EnvironmentObject var viewModel: SettingsViewModel
    
    var body: some View {
        Section {
            SettingsCellView(label: UserText.settingsSetDefault,
                             action: { viewModel.setAsDefaultBrowser() },
                             isButton: true)
            
            SettingsCellView(label: UserText.settingsAddToDock,
                             action: { viewModel.presentLegacyView(.addToDock) },
                             isButton: true)
            
            NavigationLink(destination: WidgetEducationView()) {
                SettingsCellView(label: UserText.settingsAddWidget)
            }
            
            if #available(iOS 15.0, *) {
                NavigationLink(destination: SubscriptionPIRView()) {
                    SettingsCellView(label: UserText.settingsAddWidget)
                }
            } else {
                // Fallback on earlier versions
            }

        }

    }
 
}
