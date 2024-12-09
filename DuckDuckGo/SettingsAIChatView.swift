//
//  SettingsAIChatView.swift
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

import SwiftUI
import DesignResourcesKit

struct SettingsAIChatView: View {
    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        List {

            VStack(alignment: .center) {
                Image("SettingsAIChatHero")
                    .padding(.top, -20)

                Text(UserText.aiChatFeatureName)
                    .daxTitle3()

                Text(.init(UserText.aiChatSettingsCaptionWithLinkMarkdown))
                    .tint(Color.init(designSystemColor: .accent))
                    .daxBodyRegular()
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                    .padding(.top, 12)
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)

            Section {
                if viewModel.state.aiChat.isAIChatBrowsingMenuFeatureFlagEnabled {
                    SettingsCellView(label: UserText.aiChatSettingsEnableBrowsingMenuToggle,
                                     accessory: .toggle(isOn: viewModel.aiChatBrowsingMenuEnabledBinding))
                }

                if viewModel.state.aiChat.isAIChatAddressBarFeatureFlagEnabled {
                    SettingsCellView(label: UserText.aiChatSettingsEnableAddressBarToggle,
                                     accessory: .toggle(isOn: viewModel.aiChatAddressBarEnabledBinding))
                }

            }
        }.applySettingsListModifiers(title: UserText.aiChatFeatureName,
                                     displayMode: .inline,
                                     viewModel: viewModel)
    }
}
