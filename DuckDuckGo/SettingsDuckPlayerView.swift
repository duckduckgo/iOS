//
//  SettingsDuckPlayerView.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

struct SettingsDuckPlayerView: View {
    private static let learnMoreURL = URL(string: "https://duckduckgo.com/duckduckgo-help-pages/duck-player/")!

    @EnvironmentObject var viewModel: SettingsViewModel
    var body: some View {
        List {
            VStack(alignment: .center) {
                Image("SettingsDuckPlayerHero")
                    .padding(.top, -20) // Adjust for the image padding

                Text(UserText.duckPlayerFeatureName)
                    .daxTitle3()

                Text(UserText.settingsDuckPlayerInfoText)
                    .daxBodyRegular()
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                    .padding(.top, 12)

                Link(UserText.settingsDuckPlayerLearnMore,
                     destination: SettingsDuckPlayerView.learnMoreURL)
                .daxBodyRegular()
                .accentColor(Color.init(designSystemColor: .accent))
            }
            .listRowBackground(Color.clear)

            Section {
                SettingsPickerCellView(label: UserText.settingsOpenVideosInDuckPlayerLabel,
                                       options: DuckPlayerMode.allCases,
                                       selectedOption: viewModel.duckPlayerModeBinding)
            } footer: {
                Text(UserText.settingsDuckPlayerFooter)
                    .daxFootnoteRegular()
                    .multilineTextAlignment(.center)
            }
            
        }
        .applySettingsListModifiers(title: UserText.duckPlayerFeatureName,
                                    displayMode: .inline,
                                    viewModel: viewModel)
    }
}
