//
//  SettingsNextStepsView.swift
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

struct SettingsNextStepsView: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        Section(header: Text(UserText.nextSteps)) {
            // Add App to Your Dock
            SettingsCellView(label: UserText.settingsAddToDock,
                             image: Image("SettingsAddToDock"),
                             action: { viewModel.presentLegacyView(.addToDock) },
                             isButton: true)

            // Add Widget to Home Screen
            NavigationLink(destination: WidgetEducationView()) {
                SettingsCellView(label: UserText.settingsAddWidget,
                                 image: Image("SettingsAddWidget"))
            }

            // Set Your Address Bar Position
            if viewModel.state.addressBar.enabled {
                NavigationLink(destination: SettingsAppearanceView().environmentObject(viewModel)) {
                    SettingsCellView(label: UserText.setYourAddressBarPosition,
                                     image: Image("SettingsAddressBarPosition"))
                }
            }

            // Enable Voice Search
            NavigationLink(destination: SettingsAccessibilityView().environmentObject(viewModel)) {
                SettingsCellView(label: UserText.enableVoiceSearch,
                                 image: Image("SettingsVoiceSearch"))
            }
        }

    }

}
