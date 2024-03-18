//
//  SettingsPrivacyProtectionsView.swift
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

struct SettingsPrivacyProtectionsView: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        Section(header: Text("Privacy Protections")) {
            // Default Browser
            SettingsCellView(label: "Default Browser",
                             image: Image("DefaultBrowser"),
                             action: { viewModel.setAsDefaultBrowser() },
                             webLinkIndicator: true,
                             isButton: true)

            // Private Search
            NavigationLink(destination: PrivateSearchView().environmentObject(viewModel)) {
                SettingsCellView(label: "Private Search",
                                 image: Image("Search"),
                                 statusIndicator: StatusIndicatorView(status: .on))
            }

            // Web Tracking Protection
            NavigationLink(destination: WebTrackingProtectionView().environmentObject(viewModel)) {
                SettingsCellView(label: "Web Tracking Protection",
                                 image: Image("WebTrackingProtection"),
                                 statusIndicator: StatusIndicatorView(status: .on))
            }

            // Cookie Pop-Up Protection
            NavigationLink(destination: CookiePopUpProtectionView().environmentObject(viewModel)) {
                SettingsCellView(label: "Cookie Pop-Up Protection",
                                 image: Image("CookiePopUpProtection"),
                                 statusIndicator: StatusIndicatorView(status: viewModel.cookiePopUpProtectionStatus))
            }

            // Email Protection
            NavigationLink(destination: EmailProtectionView().environmentObject(viewModel)) {
                SettingsCellView(label: "Email Protection",
                                 image: Image("EmailProtection"),
                                 action: { viewModel.openEmailProtection() },
                                 statusIndicator: StatusIndicatorView(status: viewModel.emailProtectionStatus))
            }

            // Network Protection
#if NETWORK_PROTECTION
            if viewModel.state.networkProtection.enabled {
                SettingsCellView(label: "VPN",
                                 image: Image("NetworkProtection"),
                                 action: { viewModel.presentLegacyView(.netP) },
                                 disclosureIndicator: true,
                                 isButton: true)
            }
#endif
        }

    }

}
