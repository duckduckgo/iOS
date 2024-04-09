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
import Core

struct SettingsMoreView: View {
        
    @EnvironmentObject var viewModel: SettingsViewModel
    

    var body: some View {
        Section(header: Text(UserText.settingsMoreSection)) {
            
            SettingsCellView(label: UserText.emailProtection,
                             subtitle: UserText.settingsEmailProtectionDescription,
                             action: {
                viewModel.openEmailProtection()
                Pixel.fire(pixel: .settingsEmailProtectionOpen,
                           withAdditionalParameters: PixelExperiment.parameters)
            },
                             disclosureIndicator: true,
                             isButton: true)
            
            NavigationLink(destination: DesktopDownloadView(viewModel: .init(platform: .mac))) {
                SettingsCellView(label: UserText.macBrowserTitle,
                                 subtitle: UserText.macWaitlistBrowsePrivately)
            }
            
            NavigationLink(destination: DesktopDownloadView(viewModel: .init(platform: .windows))) {
                SettingsCellView(label: UserText.windowsWaitlistTitle,
                                 subtitle: UserText.windowsWaitlistBrowsePrivately)
            }

#if NETWORK_PROTECTION
            if viewModel.state.networkProtection.enabled {
                SettingsCellView(label: UserText.netPSettingsTitle,
                                 subtitle: viewModel.state.networkProtection.status != "" ? viewModel.state.networkProtection.status : nil,
                                 action: { viewModel.presentLegacyView(.netP) },
                                 disclosureIndicator: true,
                                 isButton: true)
            }
#endif
        }

    }
}
