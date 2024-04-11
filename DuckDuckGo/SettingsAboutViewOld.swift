//
//  SettingsAboutViewOld.swift
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

struct SettingsAboutViewOld: View {

    @EnvironmentObject var viewModel: SettingsViewModel
    
    var body: some View {
        Section(header: Text(UserText.settingsAboutSection)) {

            SettingsCellView(label: UserText.settingsAboutDDG,
                             action: { viewModel.presentLegacyView(.about) },
                             disclosureIndicator: true,
                             isButton: true)
            
            SettingsCellView(label: UserText.settingsVersion,
                             accesory: .rightDetail(viewModel.state.version))
            
            SettingsCellView(label: UserText.settingsFeedback,
                             action: { viewModel.presentLegacyView(.feedback) },
                             isButton: true)

            SettingsCellView(label: UserText.settingsSendCrashReports,
                             subtitle: UserText.settingsSendCrashReportsDescription,
                             accesory: .toggle(isOn: viewModel.crashCollectionOptInStatusBinding))
        }

    }
 
}
