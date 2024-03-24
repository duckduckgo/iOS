//
//  SettingsAppearanceView.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import Core
import SwiftUI
import DesignResourcesKit

struct SettingsAppearanceView: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section {
                // App Icon
                let image = Image(uiImage: viewModel.state.appIcon.smallImage ?? UIImage())
                SettingsCellView(label: UserText.settingsIcon,
                                 action: { viewModel.presentLegacyView(.appIcon ) },
                                 accesory: .image(image),
                                 disclosureIndicator: true,
                                 isButton: true)

                // Theme
                SettingsPickerCellView(label: UserText.settingsTheme,
                                       options: ThemeName.allCases,
                                       selectedOption: viewModel.themeBinding)
            }

            if viewModel.state.addressbar.enabled {
                Section(header: Text("Address Bar")) {
                    // Address Bar Position
                    SettingsPickerCellView(label: UserText.settingsAddressBar,
                                           options: AddressBarPosition.allCases,
                                           selectedOption: viewModel.addressBarPositionBinding)

                    // Show Full Site Address
                    SettingsCellView(label: UserText.settingsFullURL,
                                     accesory: .toggle(isOn: viewModel.addressBarShowsFullURL))
                }
            }
        }
        .applySettingsListModifiers(title: "Appearance",
                                    displayMode: .inline,
                                    viewModel: viewModel)
        .onForwardNavigationAppear {
            Pixel.fire(pixel: .settingsAppearanceOpen,
                       withAdditionalParameters: PixelExperiment.parameters)
        }
    }
}
