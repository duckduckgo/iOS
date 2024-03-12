//
//  SettingsMainSettingsView.swift
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

struct SettingsMainSettingsView: View {

    @EnvironmentObject var viewModel: SettingsViewModel
    
    var body: some View {
        Section(header: Text("Main Settings")) {
            SettingsCellView(label: "General",
                             image: Image("General"),
                             action: { viewModel.presentLegacyView(.gpc) },
                             disclosureIndicator: true,
                             isButton: true)
            SettingsCellView(label: "Sync & Backup",
                             image: Image("Sync"),
                             action: { viewModel.presentLegacyView(.gpc) },
                             disclosureIndicator: true,
                             isButton: true)
            SettingsCellView(label: "Appearance",
                             image: Image("Appearance"),
                             action: { viewModel.presentLegacyView(.gpc) },
                             disclosureIndicator: true,
                             isButton: true)
            SettingsCellView(label: "Passwords",
                             image: Image("Passwords"),
                             action: { viewModel.presentLegacyView(.gpc) },
                             disclosureIndicator: true,
                             isButton: true)
            SettingsCellView(label: "Accessibility",
                             image: Image("Accessibility"),
                             action: { viewModel.presentLegacyView(.gpc) },
                             disclosureIndicator: true,
                             isButton: true)
            SettingsCellView(label: "Data Clearing",
                             image: Image("DataClearing"),
                             action: { viewModel.presentLegacyView(.gpc) },
                             disclosureIndicator: true,
                             isButton: true)
        }

    }
 
}
