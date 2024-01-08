//
//  SettingsMoreView.swift
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

struct SettingsMoreView: View {
        
    @EnvironmentObject var viewModel: SettingsViewModel
    

    var body: some View {
        Section(header: Text(UserText.settingsMoreSection)) {
            
            SettingsCellView(label: UserText.settingsEmailProtection,
                             subtitle: UserText.settingsEmailProtectionDescription,
                             action: { viewModel.openEmailProtection() },
                             asLink: true,
                             disclosureIndicator: true)
            
            SettingsCellView(label: UserText.macBrowserTitle,
                             subtitle: UserText.macWaitlistBrowsePrivately,
                             action: { viewModel.presentLegacyView(.macApp) },
                             asLink: true,
                             disclosureIndicator: true)
            
            SettingsCellView(label: UserText.windowsWaitlistTitle,
                             subtitle: UserText.windowsWaitlistBrowsePrivately,
                             action: { viewModel.presentLegacyView(.windowsApp) },
                             asLink: true,
                             disclosureIndicator: true)

#if NETWORK_PROTECTION
            if viewModel.shouldShowNetworkProtectionCell {
                SettingsCellView(label: UserText.netPNavTitle,
                                 subtitle: viewModel.state.netPSubtitle != "" ? viewModel.state.netPSubtitle : nil,
                                 action: { viewModel.presentLegacyView(.netP) },
                                 asLink: true,
                                 disclosureIndicator: true)
            }
#endif
        }

    }
}
