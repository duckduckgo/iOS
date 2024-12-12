//
//  SettingsDataClearingView.swift
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

struct SettingsDataClearingView: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section {
                // Fire Button Animation
                SettingsPickerCellView(label: UserText.settingsFirebutton,
                                       options: FireButtonAnimationType.allCases,
                                       selectedOption: viewModel.fireButtonAnimationBinding)
            }

            Section {
                // Fireproof Sites
                SettingsCellView(label: UserText.settingsFireproofSites,
                                  action: { viewModel.presentLegacyView(.fireproofSites) },
                                 disclosureIndicator: true,
                                 isButton: true)

                // Automatically Clear Data
                SettingsCellView(label: UserText.settingsClearData,
                                  action: { viewModel.presentLegacyView(.autoclearData) },
                                  accessory: .rightDetail(viewModel.state.autoclearDataEnabled
                                                         ? UserText.autoClearAccessoryOn
                                                         : UserText.autoClearAccessoryOff),
                                  disclosureIndicator: true,
                                  isButton: true)
            }
        }
        .applySettingsListModifiers(title: UserText.dataClearing,
                                    displayMode: .inline,
                                    viewModel: viewModel)
        .onFirstAppear {
            Pixel.fire(pixel: .settingsDataClearingOpen)
        }
    }
}
