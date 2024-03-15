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
import SyncUI

struct SettingsMainSettingsView: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        Section(header: Text("Main Settings")) {
            // General
            NavigationLink(destination: SettingsGeneralView().environmentObject(viewModel)) {
                SettingsCellView(label: "General",
                                 image: Image("General"))
            }

            // Sync & Backup
            SettingsCellView(label: SyncUI.UserText.syncTitle,
                             image: Image("Sync"),
                             action: { viewModel.presentLegacyView(.sync) },
                             disclosureIndicator: true,
                             isButton: true)

            // Appearance
            NavigationLink(destination: SettingsAppearanceView().environmentObject(viewModel)) {
                SettingsCellView(label: "Appearance",
                                 image: Image("Appearance"))
            }

            // Passwords
            SettingsCellView(label: UserText.settingsLogins,
                             image: Image("Passwords"),
                             action: { viewModel.presentLegacyView(.logins) },
                             disclosureIndicator: true,
                             isButton: true)

            // Accessibility
            NavigationLink(destination: SettingsAccessibilityView().environmentObject(viewModel)) {
                SettingsCellView(label: "Accessibility",
                                 image: Image("Accessibility"))
            }

            // Data Clearing
            NavigationLink(destination: SettingsDataClearingView().environmentObject(viewModel)) {
                SettingsCellView(label: "Data Clearing",
                                 image: Image("DataClearing"))
            }
        }

    }

}
