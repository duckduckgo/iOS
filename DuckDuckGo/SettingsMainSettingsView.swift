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
import SyncUI_iOS

struct SettingsMainSettingsView: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        Section(header: Text(UserText.mainSettings)) {
            // General
            NavigationLink(destination: SettingsGeneralView().environmentObject(viewModel)) {
                SettingsCellView(label: UserText.general,
                                 image: Image("SettingsGeneral"))
            }

            // Sync & Backup
            let statusIndicator = viewModel.syncStatus == .on ? StatusIndicatorView(status: viewModel.syncStatus, isDotHidden: true) : nil
            let label = viewModel.state.sync.title
            SettingsCellView(label: label,
                             image: Image("SettingsSync"),
                             action: { viewModel.presentLegacyView(.sync) },
                             statusIndicator: statusIndicator,
                             disclosureIndicator: true,
                             isButton: true)

            // Appearance
            NavigationLink(destination: SettingsAppearanceView().environmentObject(viewModel)) {
                SettingsCellView(label: UserText.settingsAppearanceSection,
                                 image: Image("SettingsAppearance"))
            }

            // Passwords
            SettingsCellView(label: UserText.settingsLogins,
                             image: Image("SettingsPasswords"),
                             action: { viewModel.presentLegacyView(.logins) },
                             disclosureIndicator: true,
                             isButton: true)

            // Accessibility
            NavigationLink(destination: SettingsAccessibilityView().environmentObject(viewModel)) {
                SettingsCellView(label: UserText.accessibility,
                                 image: Image("SettingsAccessibility"))
            }

            // Data Clearing
            NavigationLink(destination: SettingsDataClearingView().environmentObject(viewModel)) {
                SettingsCellView(label: UserText.dataClearing,
                                 image: Image("SettingsDataClearing"))
            }

            // Duck Player
            // We need to hide the settings until the user is enrolled in the experiment
            if viewModel.state.duckPlayerEnabled {
                NavigationLink(destination: SettingsDuckPlayerView().environmentObject(viewModel)) {
                    SettingsCellView(label: UserText.duckPlayerFeatureName,
                                     image: Image("SettingsDuckPlayer"))
                }
            }

            // AI Chat
            if viewModel.state.aiChat.enabled {
                NavigationLink(destination: SettingsAIChatView().environmentObject(viewModel)) {
                    SettingsCellView(label: UserText.aiChatFeatureName,
                                     image: Image("SettingsAIChat"))
                }
            }
        }

    }

}
