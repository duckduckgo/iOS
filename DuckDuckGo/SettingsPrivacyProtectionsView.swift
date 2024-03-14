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
            SettingsCellView(label: "Default Browser",
                             subtitle: "Make DuckDuckGo your default",
                             image: Image("DefaultBrowser"),
                             action: { viewModel.presentLegacyView(.gpc) },
                             disclosureIndicator: true,
                             isButton: true)
            SettingsCellView(label: "Private Search",
                             subtitle: "Search without being tracked",
                             image: Image("Search"),
                             action: { viewModel.presentLegacyView(.gpc) },
                             disclosureIndicator: true,
                             isButton: true)
            SettingsCellView(label: "Web Tracking Protection",
                             subtitle: "Automatically block web trackers",
                             image: Image("WebTrackingProtection"),
                             action: { viewModel.presentLegacyView(.gpc) },
                             disclosureIndicator: true,
                             isButton: true)
            SettingsCellView(label: "Cookie Pop-Up Protection",
                             subtitle: "Banish cookies & hide the pop-ups",
                             image: Image("CookiePopUpProtection"),
                             action: { viewModel.presentLegacyView(.gpc) },
                             disclosureIndicator: true,
                             isButton: true)
            SettingsCellView(label: "Email Protection",
                             subtitle: "Block email trackers",
                             image: Image("EmailProtection"),
                             action: { viewModel.presentLegacyView(.gpc) },
                             disclosureIndicator: true,
                             isButton: true)
        }

    }

}
