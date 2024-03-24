//
//  SettingsOthersView.swift
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

struct SettingsOthersView: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            // About
            NavigationLink(destination: AboutView().environmentObject(viewModel)) {
                SettingsCellView(label: "About",
                                 image: Image("LogoIcon"))
            }

            // Share Feedback
            SettingsCellView(label: "Share Feedback",
                             image: Image("SettingsFeedback"),
                             action: { viewModel.presentLegacyView(.feedback) },
                             isButton: true)

            // DuckDuckGo on Other Platforms
            SettingsCellView(label: "DuckDuckGo on Other Platforms",
                             image: Image("SettingsOtherPlatforms"),
                             action: { viewModel.openOtherPlatforms() },
                             webLinkIndicator: true,
                             isButton: true)
        }

    }

}
