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
        List {
            NavigationLink(destination: NetworkProtectionVPNLocationView()) {
                HStack {
                    Text(UserText.netPPreferredLocationSettingTitle).daxBodyRegular().foregroundColor(.textPrimary)
                    Spacer()
                    Text(viewModel.preferredLocation).daxBodyRegular().foregroundColor(.textSecondary)
                }
            }
            toggleSection(
                text: UserText.netPAlwaysOnSettingTitle,
                footerText: UserText.netPAlwaysOnSettingFooter
            )
            toggleSection(
                text: UserText.netPSecureDNSSettingTitle,
                footerText: UserText.netPSecureDNSSettingFooter
            )
        }
        .applyInsetGroupedListStyle()
        .navigationTitle(UserText.netPVPNSettingsTitle)
    }

    @ViewBuilder
    func toggleSection(text: String, footerText: String) -> some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(text)
                        .font(.system(size: 16))
                        .foregroundColor(.textPrimary.opacity(0.4))
                        .font(.system(size: 13))
                        .foregroundColor(.textSecondary.opacity(0.4))
                }

                // These toggles are permanantly disabled as the features are permanantly enabled. Product decision.
                Toggle("", isOn: .constant(true))
                    .disabled(true)
                    .toggleStyle(SwitchToggleStyle(tint: .controlColor))
            }
            .listRowBackground(Color.cellBackground)
        } footer: {
            Text(footerText)
                .foregroundColor(.textSecondary)
                .accentColor(Color.controlColor)
                .font(.system(size: 13))
                .padding(.top, 6)
        }
    }
}

private extension Color {
    static let textPrimary = Color(designSystemColor: .textPrimary)
    static let textSecondary = Color(designSystemColor: .textSecondary)
    static let cellBackground = Color(designSystemColor: .surface)
    static let controlColor = Color(designSystemColor: .accent)
}

#endif
