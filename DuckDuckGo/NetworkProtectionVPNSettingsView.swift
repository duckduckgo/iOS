//
//  NetworkProtectionVPNSettingsView.swift
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

#if NETWORK_PROTECTION

import SwiftUI
import DesignResourcesKit

@available(iOS 15, *)
struct NetworkProtectionVPNSettingsView: View {
    @StateObject var viewModel = NetworkProtectionVPNSettingsViewModel()

    var body: some View {
        VStack {
            List {
                Section {
                    NavigationLink(destination: NetworkProtectionVPNLocationView()) {
                        HStack {
                            Text(UserText.netPPreferredLocationSettingTitle).daxBodyRegular().foregroundColor(.textPrimary)
                            Spacer()
                            Text(viewModel.preferredLocation).daxBodyRegular().foregroundColor(.textSecondary)
                        }
                    }
                }
                toggleSection(
                    text: UserText.netPExcludeLocalNetworksSettingTitle,
                    footerText: UserText.netPExcludeLocalNetworksSettingFooter
                ) {
                    Toggle("", isOn: $viewModel.excludeLocalNetworks)
                        .onTapGesture {
                            viewModel.toggleExcludeLocalNetworks()
                        }
                }
                Section {
                    HStack(spacing: 16) {
                        Image("Info-Solid-24")
                            .foregroundColor(.icon)
                        Text(UserText.netPSecureDNSSettingFooter)
                            .daxFootnoteRegular()
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
        .applyInsetGroupedListStyle()
        .navigationTitle(UserText.netPVPNSettingsTitle)
    }

    @ViewBuilder
    func toggleSection(text: String, footerText: String, @ViewBuilder toggle: () -> some View) -> some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(text)
                        .daxBodyRegular()
                        .foregroundColor(.textPrimary)
                        .layoutPriority(1)
                }

                toggle()
                    .toggleStyle(SwitchToggleStyle(tint: .controlColor))
            }
            .listRowBackground(Color.cellBackground)
        } footer: {
            Text(footerText)
                .foregroundColor(.textSecondary)
                .accentColor(Color.controlColor)
                .daxFootnoteRegular()
                .padding(.top, 6)
        }
    }
}

private extension Color {
    static let textPrimary = Color(designSystemColor: .textPrimary)
    static let textSecondary = Color(designSystemColor: .textSecondary)
    static let cellBackground = Color(designSystemColor: .surface)
    static let controlColor = Color(designSystemColor: .accent)
    static let icon = Color(designSystemColor: .icons).opacity(0.3)
}

#endif
